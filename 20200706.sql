OUTER JOIN < == > INNER JOIN

INNER JOIN : 조인 조건을 만족하는 (조인에 성공하는) 데이터만 조회
OUTER JOIN : 조인 조건을 만족하지 않더라도 (조인에 실패하더라도) 기준이 되는 테이블 쪽의 데이터(컬럼)은
             조회가 되도록 하는 조인 방식

OUTER JOIN : 
    LEFT OUTER JOIN : 조인 키워드의 왼쪽에 위치하는 테이블을 기준삼아 OUTER JOIN 시행
    RIGHT OUTER JOIN : 조인 키워드의 오른쪽에 위치하는 테이블을 기준삼아 OUTER JOIN 시행
    FULL OUTER JOIN : LEFT OUTER + RIGHT OUTER - 중복되는것 제외

ANSI-SQL
SELECT *
FROM 테이블1 LEFT OUTER JOIN 테이블2 ON (조인 조건);


SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno);

SELECT empno, ename, mgr
FROM emp;

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e RIGHT OUTER JOIN emp m ON (e.mgr = m.empno);

ORACLE-SQL 
SELECT 데이터가 없는데 나와야하는 테이블의 컬럼
FROM 테이블1, 테이블2
WHERE 테이블1.컬럼 = 테이블2.컬럼(+);

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e, emp m 
WHERE e.mgr = m.empno(+); --기준이 emp e 이므로 조회 했을 때 안나오는 emp m 쪽에 (+)를 붙여야한다.


OUTER JOIN 시 조인 조건(ON 절에 기술)과 일반 조건(WHERE 절에 기술)적용시 주의 사항
    : OUTER JOIN 을 사용하는데 WHERE 절에 별도의 다른 조건을 기술할 경우 원하는 결과가 안나올 수 있음
      ==> OUTER JOIN 의 결과가 무시

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno AND m.deptno = 10);
    ==> deptno = 10 이 아닌 사람들의 데이터는 나오지 않는다.

ORACLE-SQL
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno(+)
  AND m.deptno(+) = 10;
  
SELECT *
FROM emp;
  
SELECT e.empno, e.ename, m.empno, m.ename, e.deptno
FROM emp e, emp m
WHERE e.mgr = m.empno(+);

SELECT ename
FROM emp
WHERE deptno = 10;
    
조인 조건을 WHERE 절로 변경한 경우
ANSI-SQL
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno)
WHERE m.deptno = 10;


위의 쿼리는 OUTER JOIN 을 적용하지 않은 아래 쿼리와 동일한 결과를 나타낸다
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno)
WHERE m.deptno = 10;

ORACLE-SQL
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno
  AND m.deptno = 10;


RIGHT OUTER JOIN : 기준 테이블이 오른쪽
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e RIGHT OUTER JOIN emp m ON (e.mgr = m.empno); --TURNER 부터는 평사원이다.

SELECT *
FROM emp;

FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno); : 14건
FROM emp e RIGHT OUTER JOIN emp m ON (e.mgr = m.empno);  : 21건


FULL OUTER JOIN : LEFT OUTER + RIGHT OUTER - 중복제거

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e FULL OUTER JOIN emp m ON (e.mgr = m.empno);

ORACLE SQL 에서는 FULL OUTER 문법을 제공하지 않음
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e, emp m
WEHRE e.mgr(+) = m.empno(+);

FULL OUTER 검증

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno)
UNION
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e RIGHT OUTER JOIN emp m ON (e.mgr = m.empno)
MINUS
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e FULL OUTER JOIN emp m ON (e.mgr = m.empno);


SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno)
UNION
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e RIGHT OUTER JOIN emp m ON (e.mgr = m.empno)
INTERSECT
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e FULL OUTER JOIN emp m ON (e.mgr = m.empno);


WHERE : 행을 제한
JOIN
GROUP FUNCTION


시도 : 서울특별시, 충청남도
시군구 : 강남구, 청주시
스토어 구분 



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



SELECT *
FROM buyprod;

SELECT *
FROM prod;

