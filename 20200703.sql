--실습 join1
oracle SQL
SELECT lprod_gu, lprod_nm, prod_id, prod_name
FROM prod, lprod
WHERE prod.prod_lgu = lprod.lprod_gu;

ansi SQL 두 테이블의 연결 컬럼명이 다르기 때문에 NATURAL JOIN, JOIN with USING 은 사용이 불가
SELECT lprod_gu, lprod_nm, prod_id, prod_name
FROM prod JOIN lprod ON (prod.prod_lgu = lprod.lprod_gu);


--실습 join2
oracle SQL
SELECT buyer_id, buyer_name, prod_id, prod_name
FROM buyer, prod -- 순서는 중요하지 않음. 
WHERE prod.prod_buyer = buyer.buyer_ID;

ansi SQL
SELECT buyer_id, buyer_name, prod_id, prod_name
FROM buyer JOIN prod ON (prod.prod_buyer = buyer.buyer_ID);


--실습 join3
oracle SQL
SELECT mem_id, mem_name, prod_id, prod_name, cart_qty
FROM(SELECT *
     FROM member, cart
     WHERE member.mem_id = cart.cart_member) a, prod
WHERE a.cart_prod = prod.prod_id;


SELECT mem_id, mem_name, prod_id, prod_name, cart_qty
FROM member, cart, prod
WHERE member.mem_id = cart.cart_member AND cart.cart_prod = prod.prod_id;


ansi SQL
SELECT buyer_id, buyer_name, prod_id, prod_name
FROM member JOIN cart ON (member.mem_id = cart.cart_member) 
            JOIN prod ON (cart.cart_prod = prod.prod_id);



--실습 join4
CUSTOMER : 고객
PRODUCT : 제품
CYCLE : 고객 제품 애음 주기

oracle SQL
SELECT customer.cid, customer.cnm, pid, day, cnt
FROM customer, cycle
WHERE customer.cid = cycle.cid AND cnm IN('brown', 'sally') ;


--실습 join5
oracle SQL
SELECT customer.cid, customer.cnm, cycle.pid, pnm, day, cnt
FROM customer, cycle, product
WHERE customer.cid = cycle.cid AND cycle.pid = product.pid 
                               AND cnm IN('brown', 'sally');
                               

--실습 join6
SELECT customer.*, cycle.pid, pnm, SUM(cnt)
FROM customer, cycle, product
WHERE customer.cid = cycle.cid AND cycle.pid = product.pid
GROUP BY customer.cid, customer.cnm, cycle.pid, pnm;


--실습 join7
SELECT product.pid, product.pnm, SUM(cnt)
FROM cycle, product
WHERE cycle.pid = product.pid
GROUP BY product.pid, product.pnm;

SELECT cycle.pid, pnm, SUM(cnt)
FROM cycle, product
WHERE cycle.pid = product.pid
GROUP BY cycle.pid, pnm;




ansi SQL
SELECT *
FROM customer;

SELECT *
FROM cycle;

SELECT *
FROM product;

SELECT *
FROM cart;

SELECT *
FROM member;

SELECT *
FROM prod;

SELECT *
FROM buyer;

SELECT *
FROM lprod;


조인 성공 여부로 데이터 조회를 결정하는 구분 방법
INNER JOIN : 조인에 성공하는 데이터만 조회하는 조인 방법
OUTER JOIN : 조인에 실패 하더라도, 개발자가 지정한 기준이 되는 테이블의 데이터는 나오도록 하는 조인
OUTER <==> INNER JOIN

복습 - 사원의 관리자 이름을 알고싶은 상황
    조회 커럼 : 사원의 사번, 사원의 이름, 사원의 관리자의 사번, 사원의 관리자의 이름

동일한 테이블끼리 조인 되었기 때문에 : SELF-JOIN
조인 조건을 만족하는 데이터만 조회 되었기 때문에 : INNER-JOIN
SELECT e.empno, e.ename, e.mgr, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno;

KING의 경우 PRESIDENT이기 때문에 mgr 컬럼의 값이 NULL ==> 조인에 실패
==> KING의 데이터는 조회되지 않음 (총 14건 데이터 중 13건의 데이터만 조인 성공)

OUTER 조인을 이용하여 조인 테이블 중 기준이 되는 테이블을 선택하면 
조인에 실패하더라도 기준 테이블의 데이터는 조회 되도록 할 수 있다
ansi SQL
테이블1 JOIN 테이블2 ON (......)
테이블1 LEFT OUTER JOIN 테이블2 ON (......)
위 쿼리는
테이블2 RIGHT OUTER JOIN 테이블1 ON (.....)

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno);


과제 (join8 ~ 13)
hr 계정에 있는 테이블 이용


