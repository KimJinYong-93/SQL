SELECT *
FROM burgerstore;


SELECT m.sido, m.sigungu, ROUND((m.m / d.d), 2) score
FROM
(SELECT sido, sigungu, COUNT(*) m
 FROM burgerstore
 WHERE storecategory IN('BURGER KING', 'KFC', 'MACDONALD')
 GROUP BY sido, sigungu) m,
(SELECT sido, sigungu, COUNT(*) d
 FROM burgerstore
 WHERE storecategory = 'LOTTERIA'
 GROUP BY sido, sigungu) d
WHERE m.sido = d.sido
  AND m.sigungu = d.sigungu
ORDER BY score DESC;

SELECT m.sido, m.sigungu, ROUND((m.m / d.d), 2) score
FROM
(SELECT sido, sigungu, COUNT(*) m
 FROM burgerstore
 WHERE storecategory IN('BURGER KING', 'KFC', 'MACDONALD')
 GROUP BY sido, sigungu) m,
 (SELECT sido, sigungu, COUNT(*) d
 FROM burgerstore
 WHERE storecategory = 'LOTTERIA'
 GROUP BY sido, sigungu) d
WHERE m.sido = d.sido
  AND m.sigungu = d.sigungu
ORDER BY score DESC;

SELECT *
FROM emp
ORDER BY mgr desc;
