#|
  CS 4820 HWK2 - Grader checks (TA-level)
  - Put this file next to HWK2_*.lisp submissions.
  - In your per-student driver, do:
      (in-package "ACL2S")
      (ld "HWK2_Student.lisp")
      (ld "checks.lisp")
      (good-bye)

  This file assumes students define:
    saexprp, lookup, saeval, *er*, aaexprp, sael->aa, aa->sael, aaeval
|#

(in-package "ACL2S")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 0) Helper: small assertion wrappers (optional)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro check-er (term)
  `(check= ,term *er*))

(defmacro check-rat (term)
  ;; check that term evaluates to a rational (not error)
  `(check= (rationalp ,term) t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1) Syntax checks (saexprp / aaexprp)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Valid SAEL
(check= (saexprp 'x) t)
(check= (saexprp 3/2) t)
(check= (saexprp '(- x)) t)
(check= (saexprp '(/ x)) t)
(check= (saexprp '(x + y)) t)
(check= (saexprp '((x + y) - (/ z))) t)
(check= (saexprp '((x ^ 2) + ((- y) * (/ z)))) t)

;; Invalid SAEL (shape wrong / ambiguous)
(check= (saexprp '(x + y + z)) nil)    ; not binary tree form
(check= (saexprp '(/ x y)) nil)        ; unary / has 1 arg
(check= (saexprp '(+ x y)) nil)        ; SAEL is infix for binary
(check= (saexprp '(- x y)) nil)        ; same
(check= (saexprp '(x ! y)) nil)        ; unknown operator

;; AAEL prefix syntax (if student defined aaexprp as in spec)
;; Note: aaexprp may not exist if they used a different recognizer name;
;; but spec says it should.
(check= (aaexprp 'x) t)
(check= (aaexprp 5) t)
(check= (aaexprp '(- x)) t)
(check= (aaexprp '(/ x)) t)
(check= (aaexprp '(+ x y)) t)
(check= (aaexprp '(* (- x) (/ y))) t)
(check= (aaexprp '(expt x 2)) t)

(check= (aaexprp '(x + y)) nil)        ; AAEL is prefix, not infix
(check= (aaexprp '(expt x)) nil)       ; wrong arity
(check= (aaexprp '(foo x y)) nil)      ; unknown operator

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2) lookup: default value and overrides
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check= (lookup 'x '()) 1)
(check= (lookup 'x '((x . 3))) 3)
(check= (lookup 'x '((a . 10) (x . 2))) 2)
(check= (lookup 'x '((a . 10))) 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3) saeval: base cases & default var value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check= (saeval 7/3 '()) 7/3)
(check= (saeval 'x '()) 1)
(check= (saeval 'x '((x . 9))) 9)
(check= (saeval '(x + 1) '()) 2)
(check= (saeval '(x + 1) '((x . -3))) -2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4) saeval: unary operators
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check= (saeval '(- 3) '()) -3)
(check= (saeval '(- x) '((x . 10))) -10)
(check= (saeval '(/ 2) '()) 1/2)
(check= (saeval '(/ x) '((x . 4))) 1/4)

;; unary divide-by-0 is error
(check-er (saeval '(/ 0) '()))
(check-er (saeval '(/ x) '((x . 0))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5) saeval: binary operators (+ - * /)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check= (saeval '(3 + 4) '()) 7)
(check= (saeval '(3 - 4) '()) -1)
(check= (saeval '(3 * 4) '()) 12)
(check= (saeval '(3 / 4) '()) 3/4)

;; division by 0 => error
(check-er (saeval '(1 / 0) '()))
(check-er (saeval '(x / y) '((x . 1) (y . 0))))

;; error propagation: any subexpression error => whole expression error
(check-er (saeval '((/ 0) + 3) '()))
(check-er (saeval '(3 + (/ 0)) '()))
(check-er (saeval '((1 / 0) * (2 + 3)) '()))
(check-er (saeval '((2 + 3) / (1 / 0)) '()))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6) saeval: exponentiation rules
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; non-integer exponent => error
(check-er (saeval '(2 ^ 1/2) '()))
(check-er (saeval '((- 1) ^ 1/2) '()))
(check-er (saeval '(4 ^ 0.5) '()))     ; 0.5 is not rational in ACL2s normally,
                                       ; but if it parses, should still error

;; integer exponent ok
(check= (saeval '(2 ^ 3) '()) 8)
(check= (saeval '(1/2 ^ 2) '()) 1/4)
(check= (saeval '((- 2) ^ 3) '()) -8)
(check= (saeval '((- 2) ^ 4) '()) 16)
(check= (saeval '(0 ^ 1) '()) 0)

;; 0^negative => error
(check-er (saeval '(0 ^ -1) '()))
(check-er (saeval '(0 ^ -2) '()))

;; 0^0: by given spec this should NOT error (expt 0 0 is 1 in ACL2)
(check= (saeval '(0 ^ 0) '()) 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7) Some algebraic identities (should hold for all assignments when defined)
;;    We test with concrete assignments to avoid heavy proof time.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (x - y) = (x + (- y))
(check= (saeval '(x - y) '((x . 5) (y . 2))) (saeval '(x + (- y)) '((x . 5) (y . 2))))
(check= (saeval '(x - y) '((x . -1) (y . 7))) (saeval '(x + (- y)) '((x . -1) (y . 7))))

;; distributivity x*(y+z) = x*y + x*z (when no errors)
(check= (saeval '(x * (y + z)) '((x . 2) (y . 3) (z . 4)))
        (saeval '((x * y) + (x * z)) '((x . 2) (y . 3) (z . 4))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 8) SAEL <-> AAEL conversions: round-trip & operator mapping
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Specific mapping sanity: ^ <-> expt
(check= (sael->aa '(x ^ 2)) '(expt x 2))
(check= (aa->sael '(expt x 2)) '(x ^ 2))

;; Round-trip on examples
(check= (aa->sael (sael->aa '((x + y) - (/ z))))
        '((x + y) - (/ z)))

(check= (sael->aa (aa->sael '(* (- x) (/ (expt y 2)))))
        '(* (- x) (/ (expt y 2))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 9) aaeval: semantics corner cases (as specified)
;;    - divide by 0 => return 0
;;    - expt: if y=0 OR y not integer => return 1
;;            else if x=0 => return 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; divide by 0 returns 0
(check= (aaeval '(/ 1 0) '()) 0)
(check= (aaeval '(/ x y) '((x . 5) (y . 0))) 0)

;; unary (/ x): if x=0 returns 0, else 1/x
(check= (aaeval '(/ 0) '()) 0)
(check= (aaeval '(/ 4) '()) 1/4)

;; expt rules
(check= (aaeval '(expt 2 0) '()) 1)
(check= (aaeval '(expt 2 1/2) '()) 1)
(check= (aaeval '(expt 0 5) '()) 0)
(check= (aaeval '(expt 2 3) '()) 8)

;; (0 ^ -2) in SAEL is error; in AAEL by rule: y is integer and y<0 and x=0 => returns 1
(check= (aaeval '(expt 0 -2) '()) 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 10) Cross-language consistency:
;;     If SAEL evaluation is not error, it matches AAEL evaluation of converted expr.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; No error cases: must match exactly
(check= (saeval '(1/2 ^ 2) '()) (aaeval (sael->aa '(1/2 ^ 2)) '()))
(check= (saeval '((x + 1) * 3) '((x . 2)))
        (aaeval (sael->aa '((x + 1) * 3)) '((x . 2))))
(check= (saeval '((x + y) / z) '((x . 1) (y . 2) (z . 3)))
        (aaeval (sael->aa '((x + y) / z)) '((x . 1) (y . 2) (z . 3))))

;; Error cases: SAEL error expected; AAEL may return a value (that's OK)
(check-er (saeval '(1 / 0) '()))
(check= (aaeval (sael->aa '(1 / 0)) '()) 0)

(check-er (saeval '(2 ^ 1/2) '()))
(check= (aaeval (sael->aa '(2 ^ 1/2)) '()) 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 11) Quick randomized-style properties (testing only, no proofs)
;;     These help catch subtle bugs without requiring theorem proving.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(property (s :saexpr a :assignment)
  :proofs? nil
  :testing? t
  :testing-timeout 10
  (let ((sv (saeval s a))
        (av (aaeval (sael->aa s) a)))
    (implies (!= sv *er*)
             (= sv av))))

(property (e :aaexpr a :assignment)
  :proofs? nil
  :testing? t
  :testing-timeout 10
  (let ((sv (saeval (aa->sael e) a))
        (av (aaeval e a)))
    (implies (!= sv *er*)
             (= sv av))))
