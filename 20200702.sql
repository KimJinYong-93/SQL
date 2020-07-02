GROUP 함수의 특징
1. NULL은 그룹함수 연산에서 제외가 된다.

부서번호별 사원의 sal, comm 컬럼의 총 합을 구하기
SELECT deptno, SUM(sal + comm), SUM(sal + NVL(comm, 0)), SUM(sal) + SUM(comm)
FROM emp
GROUP BY deptno;

NULL처리의 효율
SELECT deptno, SUM(sal) + NVL(SUM(comm), 0),
               SUM(sal) + SUM(NVL(comm, 0))
FROM emp
GROUP BY deptno;

2. GROUP BY 절에 작성된 컬럼 이외의 컬럼이 SELECT 절에 올 수 없다.
    ==> GROUP BY 절로 묶었는데 SELECT 로 다시 조회한다?? 논리적으로 맞지 않는다.
    

--실습 grp1
직원중 가장 높은 급여
직원중 가장 낮은 급여
직원의 급여 평균(소수점 두자리까지 나오도록 반올림)
직원의 급여 합
직원중 급여가 있는 직원의 수(null 제외)
직원중 상급자가 있는 직원의 수(null 제외)
전체 직원의 수
SELECT MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal), COUNT(sal), COUNT(mgr), COUNT(ename)
FROM emp;

--실습 grp2
SELECT deptno, MAX(sal), MIN(sal), ROUND(AVG(sal), 2), 
       SUM(sal), COUNT(sal), COUNT(mgr), COUNT(ename)
FROM emp
GROUP BY deptno;

--실습 grp3
SELECT (CASE 
            WHEN deptno = 30 THEN 'SALES'
            WHEN deptno = 20 THEN 'RESEARCH'
            WHEN deptno = 10 THEN 'ACCOUNTING'
            ELSE 'DDIT'
        END) DNAME,
       MAX(sal), MIN(sal), ROUND(AVG(sal), 2), 
       SUM(sal), COUNT(sal), COUNT(mgr), COUNT(ename)
FROM emp
GROUP BY deptno; -- 여기에 케이스 구문을 작성해도 된다.

--실습 grp4
--emp 테이블을 이용하여 직원의 입사 년월별로 몇명의 직원이 입사했는지 조회하는 쿼리를 작성하세요.
SELECT hire_YYYYMM, COUNT(hire_YYYYMM) cnt
FROM(SELECT TO_CHAR(hiredate, 'YYYYMM') hire_YYYYMM
     FROM emp)
GROUP BY hire_YYYYMM;

--실습 grp5
--실습 grp4 에서 입사 년별로만 바꿈
SELECT hire_YYYY, COUNT(hire_YYYY) cnt
FROM(SELECT TO_CHAR(hiredate, 'YYYY') hire_YYYY
     FROM emp)
GROUP BY hire_YYYY;

--실습 grp6
--회사에 존재하는 부서의 개수는 몇개인지 조회하는 쿼리를 작성하시오(dept 테이블 사용)
SELECT COUNT(*) cnt
FROM dept;

--실습 grp7
--직원이 속한 부서의 개수를 조회하는 쿼리를 작성하시오(emp 테이블 사용)
SELECT COUNT(*) cnt
       FROM(SELECT deptno
            FROM emp
            GROUP BY deptno);

SELECT COUNT(COUNT(deptno))
FROM emp
GROUP BY deptno;


--------------------------------------------------------------------------------------------------


JOIN : 컬럼을 확장하는 방법(데이터 연결한다)
       다른 테이블의 컬럼을 가져온다
RDBMS가 중복을 최소화하는 구조이기 때문에 하나의 테이블에 데이터를 전부 담지 않고, 목적에 맞게 설계한 
테이블에 데이터가 분산된다. 하지만 데이터를 조회할 때 다른 테이블의 데이터를 연결하여 컬럼을 가져올 수 있다.

ANSI-SQL : American National Standard Institute SQL
ORACLES-SQL 문법 

JOIN : ANSI-SQL
       ORACLE-SQL의 차이가 다소 발생  ==> 회사마다 사용하는게 다름
       
ANSI-SQL join
NATURAL JOIN : 조인하고자 하는 테이블간 컬럼명이 동일할 경우 해당 컬럼으로 행을 연결
               컬럼 이름 뿐만 아니라 데이터 타입도 동일해야함
문법 : 
SELECT 컬럼...
FROM 테이블1 NATURAL JOIN 테이블2

emp, dept 두 테이블의 공통된 이름을 갖는 컬럼 : deptno 

SELECT emp.empno, emp.ename, emp.deptno, dname
FROM emp NATURAL JOIN dept; ==> JOIN 조건으로 사용한 컬럼은 테이블 한정자를 붙이면 에러(ANSI-SQL)

위의 쿼리를 ORACLE-SQL 버전으로 수정
오라클에서는 조인 조건을 WHERE절에 기술
행을 제한하는 조건, 조인 조건 ==> WHERE 절에 기술

SELECT emp.*, dept.deptno, dname
FROM emp, dept
WHERE emp.deptno = dept.deptno; (!= 일때도 생각해보자)

ANSI-SQL : JOIN with USING
조인 테이블간 동일한 이름의 컬럼이 복수개 인데 이름이 같은 컬럼중 일부로만 조인 하고 싶을 때 사용

SELECT *
FROM emp JOIN dept USING (deptno);

위의 쿼리를 ORACLE 조인으로 변경하면?

SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno;

ANSI-SQL : JOIN with ON
위에서 배운 NATURAL JOIN, JOIN with USING의 경우 조인 테이블의 조인컬럼이 이름이 같아야 한다는 
제약 조건이 있음. 설계상 두 테이블의 컬럼 이름이 다를수도 있음. 컬럼 이름이 다를경우 개발자가 직접 
조인 조건을 기술할 수 있도록 제공해주는 문법

SELECT *
FROM emp JOIN dept ON (emp.deptno = dept.deptno);

ORACLE-SQL

SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno;

SELF-JOIN : 동일한 테이블끼리 조인 할 때 지칭하는 명칭
            (별도의 키워드가 아니다)
            
SELECT 사원번호, 사원이름, 사원의 상사 사원번호, 사원의 상사 이름
FROM emp;

KING의 경우 상사가 없기 때문에 조인에 실패한다
총 행의 수는 13건이 조회된다
SELECT e.empno, e.ename, e.mgr, m.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno);

사원중 사원의 번호가 7369~7698인 사원만 대상으로 해당 사원의 사원번호, 이름, 상사의 사원번호, 
상사의 이름
--ORACLE-SQL
SELECT e.empno, e.ename, e.mgr, m.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno)
WHERE e.empno BETWEEN 7369 AND 7698;

SELECT a.*, emp.ename
FROM(SELECT empno, ename, mgr
     FROM emp
     WHERE empno BETWEEN 7369 AND 7698) a, emp
WHERE a.mgr = emp.empno;

--ANSI-SQL
SELECT a.*, emp.ename
FROM(SELECT empno, ename, mgr
     FROM emp
     WHERE empno BETWEEN 7369 AND 7698) a JOIN emp ON (a.mgr = emp.empno);
     

NON-EQUI-JOIN : 조인 조건이 =이 아닌 조인
 != 값이 다를 때 연결

SELECT *
FROM salgrade;

SELECT empno, ename, sal, grade
FROM emp, salgrade
WHERE sal BETWEEN losal AND hisal;

--실습 join0
SELECT empno, ename, emp.deptno, dname
FROM emp, dept
WHERE emp.deptno = dept.deptno;

--실습 join0_1
SELECT *
FROM(SELECT empno, ename, dept.deptno a, dname
     FROM emp, dept
     WHERE emp.deptno = dept.deptno)
WHERE a IN (10, 30);

SELECT empno, ename, dept.deptno, dname
FROM emp, dept
WHERE emp.deptno = dept.deptno
  AND emp.deptno IN (10, 30);
  

과제 join0_2 ~ join0_4
    youtube 에서 노마드 코더 동영상 시청 - 누구나 코딩을 할 수 있다??
                                      - 자꾸만 에러가 나오는데 왜그런걸까요??