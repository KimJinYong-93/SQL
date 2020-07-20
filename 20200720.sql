GROUPING(column) - 0, 1
0 - 컬럼이 소계 계산에 사용 되지 않았다. (GROUP BY 컬럼으로 사용됨)
1 - 컬럼이 소계 계산에 사용 되었다.

job 컬럼이 소계계산으로 사용되어 null값이 나온 것인지 정말 컬럼의 값이 null인 행들이 
GROUP BY 된 것인지 알려면 GROUPING 함수를 사용해야 정확한 값을 알 수 있다.
그래서 아래 NVL 함수 사용은 잘못된 풀이이다.

SELECT NVL(job, '총계'), deptno, 
       GROUPING(job), GROUPING(deptno),
       SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY ROLLUP (job, deptno);

GROUPING(job) 값이 1이면 '총계', 0이면 job
SELECT DECODE(GROUPING(job), 1, '총계', job) job, deptno,
       GROUPING(job), GROUPING(deptno),
       SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY ROLLUP (job, deptno);

                        --------------------------------------------------

NVL 함수를 사용하지 않고 GROUPING 함수를 사용해야 하는 이유

SELECT job, mgr, GROUPING(job), GROUPING(mgr), SUM(sal)
FROM emp
GROUP BY ROLLUP (job, mgr);

-----------------------------------------------------------------------------------------------
                        
--실습 GROUP_AD2-1
SELECT DECODE(GROUPING(job), 1, '총', job) job,
       DECODE(CASE
                WHEN GROUPING(job) = 0 AND GROUPING(deptno) = 0 THEN deptno
                WHEN GROUPING(job) = 0 AND GROUPING(deptno) = 1 THEN 1
                ELSE 0
              END, 1, '소계', 0, '계', deptno) deptno,
       GROUPING(job), GROUPING(deptno),
       SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY ROLLUP (job, deptno);


SELECT CASE
        WHEN GROUPING(job) = 1 THEN '총'
        WHEN GROUPING(job) = 0 THEN job
       END job,
       CASE
        WHEN GROUPING(job) = 1 AND GROUPING(deptno) = 1 THEN '계'
        WHEN GROUPING(job) = 0 AND GROUPING(deptno) = 1 THEN '소계'
        WHEN GROUPING(job) = 0 AND GROUPING(deptno) = 0 THEN TO_CHAR(deptno)
       END deptno, --GROUPING(job), GROUPING(deptno)
       SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY ROLLUP (job, deptno);


SELECT DECODE(GROUPING(job), 1, '총', job) job,
       DECODE(GROUPING(job) + GROUPING(deptno), 2, '계', 1, '소계', TO_CHAR(deptno))deptno,
       --GROUPING(job), GROUPING(deptno)
       SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY ROLLUP (job, deptno);

-----------------------------------------------------------------------------------------------

--실습 GROUP_AD3

SELECT deptno, job, SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY ROLLUP (deptno, job);

-----------------------------------------------------------------------------------------------

--실습 GROUP_AD4

SELECT dname, job, SUM(sal + NVL(comm, 0)) sal
FROM emp e, dept d
WHERE e.deptno = d.deptno
GROUP BY ROLLUP (dname, job)
ORDER BY dname, job DESC;

-----------------------------------------------------------------------------------------------

--실습 GROUP_AD5

SELECT DECODE(GROUPING(dname), 1, '총합', dname) dname, job, SUM(sal + NVL(comm, 0)) sal
FROM emp e, dept d
WHERE e.deptno = d.deptno
GROUP BY ROLLUP (dname, job)
ORDER BY dname, job DESC;

-----------------------------------------------------------------------------------------------

확장된 GROUP BY
1. ROLLUP (O) - 컬럼 기술에 방향성이 존재
      GROUP BY ROLLUP (job, deptno) != GROUP BY ROLLUP (deptno, job)
      GROUP BY job, deptno             GROUP BY deptno, job
      GROUP BY job                     GROUP BY deptno
      GROUP BY ''                      GROUP BY ''
      단점 - 개발자가 필요가 없는 서브그룹을 임의로 제거할 수 없다.
      
2. GROUPING SETS (O) - 필요한 서브그룹을 임의로 지정하는 형태
   ==> 복수의 GROUP BY 를 하나로 합쳐서 결과를 돌려주는 형태
   GROUP BY GROUPING SETS(col1, col2)
   GROUP BY col1
   UNION ALL
   GROUP BY col2
   
   GROUP BY GROUPING SETS(col2, col1)
   GROUP BY col2
   UNION ALL
   GROUP BY col1
   
   GROUPING SETS 의 경우 ROLLUP 과는 다르게 컬럼 나열순서가 데이터자체에 영향을 미치지 않음
   
   복수 컬럼으로 GROUP BY
   GROUP BY col1, col2
   UNION ALL
   GROUP BY col1
   ==> GROUPING SETS ((col1, col2), col1)

GROUPING SETS 실습

SELECT job, deptno, SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY GROUPING SETS (job, deptno);

위 쿼리를 UNION ALL 로 풀어 쓰기
SELECT job, null, SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY job

UNION ALL

SELECT null, deptno, SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY deptno;

                        --------------------------------------------------

SELECT job, deptno, mgr, SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY GROUPING SETS ((job, deptno), mgr);

                        --------------------------------------------------
                        
3. CUBE
GROUP BY 를 확장한 구문
CUBE 절에 나열한 모든 가능한 조합으로 서브그룹을 생성
GROUP BY CUBE(job, deptno);

GROUP BY job, deptno
GROUP BY job
GROUP BY      deptno
GROUP BY 

SELECT job, deptno, SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY CUBE (job, deptno);

CUBE 의 경우 기술한 컬럼으로 모든 가능한 조합으로 서브그룹을 생성한다.
가능한 서브그룹은 2^기술한컬럼개수
기술한 컬럼이 3개만 넘어도 생성되는 서브그룹의 개수가 8개가 넘기 때문에 실제 필요하지 않은 서브그룹이
포함될 가능성이 높다 ==> ROLLUP, GROUPING SETS 보다 활용성이 떨어진다.

-----------------------------------------------------------------------------------------------

SELECT job, deptno, mgr, SUM(sal + NVL(comm, 0)) sla_sum
FROM emp
GROUP BY job, ROLLUP(deptno), CUBE(mgr);

SELECT job, deptno, mgr, SUM(sal + NVL(comm, 0)) sal
FROM emp
GROUP BY job, ROLLUP(job, deptno), CUBE(mgr);

1. 서브그룹을 나열하기
    GROUP BY (job)
    GROUP BY (job, deptno)
    GROUP BY (job, deptno, mgr)
    GROUP BY (job, mgr)

2. 엑셀에 1번의 서브그룹별로 색상을 칠해보자

-----------------------------------------------------------------------------------------------
[ 서브쿼리 advanced ]

1. emp_test 테이블을 삭제
DROP TABLE emp_test;

2. emp 테이블을 이용하여 emp_test 테이블을 생성 (모든 행, 모든 컬럼)
CREATE TABLE emp_test AS
SELECT *
FROM emp
WHERE 1 = 1;

3. emp_test 테이블에 dname(VARCHAR2(14)) 컬럼을 추가
ALTER TABLE emp_test ADD (dname VARCHAR2(14)); 

                        --------------------------------------------------
                        
SELECT empno, ename, deptno, (SELECT dname FROM dept WHERE dept.deptno = emp_test.deptno)
FROM emp_test;

WHERE 절이 존재하지 않음 ==> 모든 행에 대해서 업데이트를 실행
UPDATE emp_test SET dname = (SELECT dname 
                             FROM dept 
                             WHERE dept.deptno = emp_test.deptno);
                             
SELECT *
FROM emp_test;

sub_all
1. dept_test 테이블을 삭제
DROP TABLE dept_test;

2. dept 테이블을 이용하여 dept_test 생성(모든 행, 모든 컬럼)
CREATE TABLE dept_test AS
SELECT *
FROM dept
WHERE 1 = 1;

3. dept_test 테이블에 empcnt(NUMBER) 컬럼을 추가
ALTER TABLE dept_test ADD (empcnt NUMBER);

4. subquery 를 이용하여 dept_test 테이블의 empcnt 컬럼을 해당 부서원 수로 update를 실행
UPDATE dept_test SET empcnt = (SELECT COUNT(*)
                               FROM emp
                               WHERE dept_test.deptno = emp.deptno
                               GROUP BY deptno);

SELECT *
FROM dept_test;