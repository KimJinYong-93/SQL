과제 outerjoin1~5

--실습 outerjoin1
SELECT buy_date, buy_prod, prod_id, prod_name, buy_qty
FROM buyprod b, prod p
WHERE b.buy_prod(+) = p.prod_id
  AND buy_date(+) = '2005/01/25';


--실습 outerjoin2
SELECT NVL(buy_date, '2005/01/25') buy_date, buy_prod, prod_id, prod_name, buy_qty
FROM buyprod b, prod p
WHERE b.buy_prod(+) = p.prod_id
  AND buy_date(+) = '2005/01/25';


--실습 outerjoin3
SELECT NVL(buy_date, '2005/01/25') buy_date, buy_prod, prod_id, prod_name, 
       NVL(buy_qty, 0) buy_qty
FROM buyprod b, prod p
WHERE b.buy_prod(+) = p.prod_id
  AND buy_date(+) = '2005/01/25';


--실습 outerjoin4
SELECT p.pid, pnm, NVL(cid, 1) cid, NVL(day, 0) day, NVL(cnt, 0) cnt
FROM cycle c, product p
WHERE c.pid(+) = p.pid
  AND c.cid(+) IN (1);


--실습 outerjoin5
SELECT p.pid, pnm, NVL(c.cid, 1) cid, NVL(cnm, 'brown') cnm, NVL(day, 0) day,
       NVL(cnt, 0) cnt
FROM cycle c, product p, customer cc
WHERE c.pid(+) = p.pid AND c.cid = cc.cid(+)
  AND c.cid(+) = 1;