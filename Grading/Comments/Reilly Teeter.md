[https://github.com/rteeter1618/car_hwk2/blob/master/hwk2.lisp](https://nam12.safelinks.protection.outlook.com/?url=https%3A%2F%2Fgithub.com%2Frteeter1618%2Fcar_hwk2%2Fblob%2Fmaster%2Fhwk2.lisp&data=05%7C02%7Clu.mingqi%40northeastern.edu%7C62f9747f653b4cf8d26d08de5d10c464%7Ca8eec281aaa34daeac9b9a398b9215e7%7C0%7C0%7C639050523694527515%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=Bk8eUPy6lw4lDj0xjUhpXyRdJ7NjvNVElZkX5VMxWu0%3D&reserved=0 "Original URL: https://github.com/rteeter1618/car_hwk2/blob/master/hwk2.lisp. Click or tap if you trust this link.")

98

Please use at least (modeling-validate-defs) instead of (modeling-start). I changed the setting when grading and it passed the test.

In `4. (1 / (x / y)) = (y / x), for saexpr's x, y`, we do not need the hypothesis not error. This is because when any of them is error, the whole term will be error. The hypothesis can be `(not (and (!= 0 (saeval x a)) (== 0 (saeval y a))))`.