[https://github.com/amanolios/cs4820](https://nam12.safelinks.protection.outlook.com/?url=https%3A%2F%2Fgithub.com%2Famanolios%2Fcs4820&data=05%7C02%7Clu.mingqi%40northeastern.edu%7Cbc4c2d7e5b984aed5b3a08de5cfbf6e9%7Ca8eec281aaa34daeac9b9a398b9215e7%7C0%7C0%7C639050434353841718%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=uv7%2FF6MpdUcqDs4jDcHeZUJTCnVZBpfwjBtD5YdqoUQ%3D&reserved=0 "Original URL: https://github.com/amanolios/cs4820. Click or tap if you trust this link.")

96

In `3. (x * (y + z)) = ((x * y) + (x * z)), for saexpr's x, y, z`, we do not need the hypothesis that they are not error. This is because when any of them is error, the whole term will be error.

In `4. (1 / (x / y)) = (y / x), for saexpr's x, y`, we do not need the hypothesis that they are not error.  The hypothesis can be `(not (and (!= 0 (saeval x a)) (== 0 (saeval y a))))`.

In `5. (0 ^ x) = 0, for saexpr x`, `(not (erp (saeval x a)))` is redundant since it is implied by `(posp (saeval x a))`. 

In `6. (x ^ ((2 * y) / y)) = (x ^ 2), for saexpr's x, y`, we do not need the hypothesis that x is not error. 