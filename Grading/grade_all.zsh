#!/bin/zsh
set -euo pipefail

###############################################################################
# grade_all.sh  (macOS + zsh)
#
# Purpose:
#   Batch-run ACL2s on every HWK2_*.lisp file in the current folder,
#   then load checks.lisp (your TA tests) WITHOUT modifying student files.
#
# Output:
#   grading_out/summary.txt                 (one-line status per student)
#   grading_out/logs/HWK2_Student.txt       (full ACL2s output per student)
#   grading_out/drivers/HWK2_Student.lsp    (auto-generated driver per student)
#
# Usage:
#   1) Put this script in the same folder as HWK2_*.lisp and checks.lisp
#   2) chmod +x grade_all.sh
#   3) ./grade_all.sh
#
# Configuration via env vars (optional):
#   ACL2S_BIN=/path/to/acl2s      # If "acl2s" is not in your PATH
#   TIMEOUT_SECS=180              # Per-student timeout (default: 120)
#   LOAD_SOLUTION=1               # Also (ld "Solution.lisp") before student file
###############################################################################

# ======= Configuration =======
ACL2S_BIN="${ACL2S_BIN:-acl2s}"          # ACL2s executable name/path
TIMEOUT_SECS="${TIMEOUT_SECS:-120}"      # Timeout per student (seconds)
LOAD_SOLUTION="${LOAD_SOLUTION:-0}"      # Whether to load Solution.lisp first
SOLUTION_FILE="Solution.lisp"            # Optional solution filename
CHECKS_FILE="checks.lisp"                # Your TA test file (required)

OUTDIR="grading_out"
DRIVER_DIR="${OUTDIR}/drivers"
LOG_DIR="${OUTDIR}/logs"
SUMMARY="${OUTDIR}/summary.txt"
# ============================

mkdir -p "$DRIVER_DIR" "$LOG_DIR"
: > "$SUMMARY"

# --- Verify ACL2s exists ---
if ! command -v "$ACL2S_BIN" >/dev/null 2>&1; then
  echo "[ERROR] Cannot find ACL2s executable: $ACL2S_BIN" | tee -a "$SUMMARY"
  echo "        Fix by setting ACL2S_BIN, e.g.:" | tee -a "$SUMMARY"
  echo "        export ACL2S_BIN=/path/to/acl2s" | tee -a "$SUMMARY"
  exit 1
fi

# --- Verify checks.lisp exists ---
if [[ ! -f "$CHECKS_FILE" ]]; then
  echo "[ERROR] Missing ${CHECKS_FILE} in $(pwd)" | tee -a "$SUMMARY"
  echo "        Put checks.lisp in the same folder as this script." | tee -a "$SUMMARY"
  exit 1
fi

echo "[INFO] Using ACL2s: $(command -v "$ACL2S_BIN")" | tee -a "$SUMMARY"
echo "[INFO] Working dir: $(pwd)" | tee -a "$SUMMARY"
echo "[INFO] Timeout per file: ${TIMEOUT_SECS}s" | tee -a "$SUMMARY"
echo "[INFO] LOAD_SOLUTION=${LOAD_SOLUTION}" | tee -a "$SUMMARY"
echo "" | tee -a "$SUMMARY"

# macOS doesn't always have GNU 'timeout'. Use Perl alarm as a portable timeout.
run_with_timeout () {
  local secs="$1"
  shift
  perl -e 'alarm shift; exec @ARGV' "$secs" "$@"
}

# Helper: extract suspicious lines (optional; makes summary easier to scan)
extract_suspicious () {
  local logfile="$1"
  # Common keywords indicating issues in ACL2/ACL2s output
  grep -E -i -n \
    "HARD ACL2 ERROR|ACL2 Error|Error|error|FAILED|abort|guard|termination|counterexample|Violation" \
    "$logfile" | head -n 25 || true
}

# Iterate over all submissions matching HWK2_*.lisp
found_any=0
for f in HWK2_*.lisp; do
  if [[ ! -f "$f" ]]; then
    continue
  fi
  found_any=1

  base="${f:r}"                                  # filename without .lisp
  driver="${DRIVER_DIR}/${base}_driver.lsp"      # generated driver file
  log="${LOG_DIR}/${base}.txt"                   # per-student log

  # Generate a driver that:
  #   1) sets package
  #   2) (optional) loads Solution.lisp
  #   3) loads the student's submission
  #   4) loads checks.lisp (your TA tests)
  #   5) exits ACL2
  {
    echo '(in-package "ACL2S")'
    echo ''
    if [[ "$LOAD_SOLUTION" == "1" && -f "$SOLUTION_FILE" ]]; then
      echo ';;; Optional: load reference solution first'
      echo "(ld \"${SOLUTION_FILE}\")"
      echo ''
    fi
    echo ';;; Load student submission'
    echo "(ld \"${f}\")"
    echo ''
    echo ';;; Load TA checks (black-box tests)'
    echo "(ld \"${CHECKS_FILE}\")"
    echo ''
    echo ';;; Exit ACL2'
    echo '(good-bye)'
  } > "$driver"

  echo "===== ${f} =====" | tee -a "$SUMMARY"
  echo "[INFO] log -> ${log}" | tee -a "$SUMMARY"

  # Run ACL2s with driver as stdin; redirect stdout+stderr to log.
  # Disable 'set -e' for this command so we can continue after failures.
  set +e
  run_with_timeout "$TIMEOUT_SECS" "$ACL2S_BIN" < "$driver" > "$log" 2>&1
  code=$?
  set -e

  if [[ $code -eq 0 ]]; then
    # Note: ACL2s may still print FAILED checks but exit 0.
    # We'll also scan for "FAILED" in the log to flag it.
    if grep -E -i "FAILED" "$log" >/dev/null 2>&1; then
      echo "[WARN] exit=0 but found FAILED checks" | tee -a "$SUMMARY"
      extract_suspicious "$log" | sed 's/^/  /' | tee -a "$SUMMARY"
    else
      echo "[OK] exit=0" | tee -a "$SUMMARY"
    fi
  else
    echo "[FAIL] exit=${code}" | tee -a "$SUMMARY"
    extract_suspicious "$log" | sed 's/^/  /' | tee -a "$SUMMARY"
  fi

  echo "" | tee -a "$SUMMARY"
done

if [[ $found_any -eq 0 ]]; then
  echo "[WARN] No files matched HWK2_*.lisp in $(pwd)" | tee -a "$SUMMARY"
fi

echo "[DONE] Summary: ${SUMMARY}"
echo "[DONE] Logs:    ${LOG_DIR}/"
echo "[DONE] Drivers: ${DRIVER_DIR}/"
