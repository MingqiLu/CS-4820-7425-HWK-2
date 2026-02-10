[https://git.sr.ht/~ekez/computer-aided-reasoning](https://nam12.safelinks.protection.outlook.com/?url=https%3A%2F%2Fgit.sr.ht%2F~ekez%2Fcomputer-aided-reasoning&data=05%7C02%7Clu.mingqi%40northeastern.edu%7Cd514ae2e3e6347cf615008de5ba0631d%7Ca8eec281aaa34daeac9b9a398b9215e7%7C0%7C0%7C639048941706586328%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=GJH5vmPV1mwoIirKQrrRJuM32vgiJIucWMy3qdIZCaw%3D&reserved=0 "Original URL: https://git.sr.ht/~ekez/computer-aided-reasoning. Click or tap if you trust this link.")

100 (+ 25)

In `4. (1 / (x / y)) = (y / x), for saexpr's x, y`, the property holds when x=0 and y!=0. The hypothesis can be `(not (and (!= 0 (saeval x a)) (== 0 (saeval y a))))`.