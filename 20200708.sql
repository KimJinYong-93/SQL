SELECT 절 중요한 것
1. GROUP BY (여러개의 행을 하나의 행으로 묶는 행위)
2. JOIN
3. 서브쿼리 
    서브쿼리 분류
    1. 사용위치
    2. 반환하는 행, 컬럼의 개수
    3. 서브쿼리에서 메인쿼리의 컬럼 사용 유무(상호연관 / 비상호연관)
        : 비상호연관 서브쿼리의 경우 단독으로 실행 가능
        : 상호연관 서브쿼리의 경우 실행하기 위해서 메인쿼리의 컬럼을 사용하기 때문에 단독으로 실행 불가
        
[ sub2 : 사원들의 급여 평균보다 높은 급여를 받는 직원 ];

SELECT *
FROM emp
WHERE sal > (SELECT AVG(sal)
             FROM emp);
             
[ 사원이 속한 부서의 급여 평균보다 높은 급여를 받는 사원 정보 조회 ]
SELECT *
FROM emp
WHERE sal > (SELECT AVG(sal)
             FROM emp e
             WHERE e.deptno = emp.deptno);
             --위의 문제와 서브쿼리가 메인쿼리의 테이블을 참조하는 건지 아닌지 차이 
             
전체사원의 정보를 조회, 조인 없이 해당 사원이 속한 부서의 부서이름 가져오기
SELECT empno, ename, deptno, (SELECT dname FROM dept WHERE deptno = emp.deptno)
FROM emp;

--실습sub3
SELECT *
FROM emp
WHERE deptno IN (SELECT deptno
                 FROM emp 
                 WHERE ename IN ('SMITH', 'WARD'));
                 
[ NULL과 IN, NULL과 NOT IN ]
** IN, NOT IN 이용시 NULL값의 존재 유무에 따라 원하지 않는 결과가 나올 수 있다.


WHERE mgr IN (7902, null)
==> mgr = 7902 OR empno = null
==> mgr값이 7902 이거나 [mgr값이 null인 데이터]
SELECT *
FROM emp
WHERE mgr IN (7902, NULL);

WHERE mgr NOT IN (7902, NULL)
==> NOT (mgr = 7902 OR mgr = null)
==> mgr != 7902 AND mgr != null
SELECT *
FROM emp
WHERE NOT (mgr = 7902 OR mgr = null);
            

[ pairwise, non-pairwise ]
한 행의 컬럼 값을 하나씩 비교하는 것 : non-pairwise
한 행의 복수 컬럼을 비교하는 것 : pairwise
SELECT *
FROM emp
WHERE job IN ('MANAGER', 'CLERK');

SELECT *
FROM emp
WHERE (mgr, deptno) IN (SELECT mgr, deptno
                        FROM emp
                        WHERE empno IN (7499, 7782)); --pairwise (6건)

SELECT *
FROM emp
WHERE mgr IN (SELECT mgr
              FROM emp
              WHERE empno IN (7499, 7782))
  AND deptno IN (SELECT deptno
                 FROM emp
                 WHERE empno IN (7499, 7782)); --non-pairwise (7건)
                 
SELECT *
FROM emp
WHERE mgr IN (7499, 7782)
  AND deptno IN (10, 30);                 

non-pairwise
7698,   30
7698,   10
7839,   30
7839,   10


--실습 sub4
INSERT INTO dept VALUES (99, 'ddit', 'daejeon');

SELECT * 
FROM dept
WHERE deptno NOT IN (SELECT deptno
                     FROM emp);
--                     WHERE dept.deptno = emp.deptno);

--실습 sub5
SELECT *
FROM product
WHERE pid NOT IN (SELECT pid
                  FROM cycle
                  WHERE cid = 1);

--실습 sub6
SELECT *
FROM cycle
WHERE cid = 1 
  AND pid IN (SELECT pid
              FROM cycle
              WHERE cid = 2);
