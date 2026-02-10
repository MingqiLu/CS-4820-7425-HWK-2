[https://github.com/Rat719/CS4820/tree/main](https://nam12.safelinks.protection.outlook.com/?url=https%3A%2F%2Fgithub.com%2FRat719%2FCS4820%2Ftree%2Fmain&data=05%7C02%7Clu.mingqi%40northeastern.edu%7C09979c22040143e1365c08de5d142474%7Ca8eec281aaa34daeac9b9a398b9215e7%7C0%7C0%7C639050538195331731%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=kKksRzS1%2FhbWPBDdkHSd8TQbZHCY%2BJaM4uoObV%2FB2yA%3D&reserved=0 "Original URL: https://github.com/Rat719/CS4820/tree/main. Click or tap if you trust this link.")

99

In `4. (1 / (x / y)) = (y / x), for saexpr's x, y`, we do not need the hypothesis not error. This is because when any of them is error, the whole term will be error. The hypothesis can be `(not (and (!= 0 (saeval x a)) (== 0 (saeval y a))))`.

In `6. (x ^ ((2 * y) / y)) = (x ^ 2), for saexpr's x, y`, we do not need the hypothesis that x is not error. 

