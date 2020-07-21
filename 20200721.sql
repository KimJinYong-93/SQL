확장된 GROUP BY
==> 서브그룹을 자동으로 생성
    만약 이런 구문이없다면 개발자가 직접 SELECT 쿼리를 여러개 작성해서 UNION ALL 을 시행
    ==> 동일한 테이블을 여러번 조회 ==> 성능 저하
    
1.ROLLUP
    1-1. ROLLUP 절에 기술한 컬럼을 오른쪽에서 부터 지워나가며 서브그룹을 생성
    1-2. 생성되는 서브 그룹 : ROLLUP 절에 기술한 컬럼 개수 + 1
    1-3. ROLLUP 절에 기술한 컬럼의 순서가 결과에 영향을 미친다.
    
2. GROUPING SETS 
    2-1. 사용자가 원하는 서브그룹을 직접 지정하는 형태
    2-2. 컬럼 기술의 순서는 결과 집합에 영향을 미치지 않음(집합)
    
3. CUBE
    3-1. CUBE 절에 기술한 컬럼의 가능한 모든 조합으로 서브그룹을 생성
    3-2. 잘 안쓴다.. 서브그룹이 너무 많이 생성됨(2^CUBE 절에기술한 컬럼개수)
    
-----------------------------------------------------------------------------------------------
    
[ sub_a2 ]

SELECT *
FROM dept_test;

1. dept_test 테이블의 empcnt 컬럼 삭제
ALTER TABLE dept_test DROP (empcnt);

2. 2개의 신규 데이터 입력
INSERT INTO dept_test VALUES (99, 'ddit1', 'daejeon');
INSERT INTO dept_test VALUES (98, 'ddit2', 'daejeon');

3. 부서(dept_test)중에 직원이 속하지 않은 부서를 삭제
   서브쿼리를 사용하여  삭제 대상 - 40, 98, 99
    1. 비상호연관
    DELETE dept_test
    WHERE deptno NOT IN (SELECT deptno
                         FROM emp);
    
    2. 상호연관
    DELETE dept_test
    WHERE NOT EXISTS (SELECT 'X'
                      FROM emp
                      WHERE emp.deptno = dept_test.deptno);
    
    DELETE dept_test
    WHERE deptno NOT IN (SELECT deptno
                         FROM emp
                         WHERE emp.deptno = dept_test.deptno);

-----------------------------------------------------------------------------------------------

[ 실습 sub_a3 ]

SELECT *
FROM emp_test;

ALTER TABLE emp_test DROP (dname);

SELECT * FROM emp_test WHERE sal < (SELECT AVG(sal)
                                    FROM emp_test e
                                    WHERE emp_test.deptno = e.deptno);

UPDATE emp_test SET sal = sal + 200
WHERE sal < (SELECT AVG(sal)
             FROM emp_test e
             WHERE emp_test.deptno = e.deptno);

-----------------------------------------------------------------------------------------------

[ 중복제거 ]

SELECT DISTINCT deptno
FROM emp;

-----------------------------------------------------------------------------------------------

[ WITH ]
쿼리 블럭을 생성하고 같이 실행되는 SQL 에서 해당 쿼리 블럭을 반복적으로 사용할 때 성능 향상 효과를
기대할 수 있다. WITH 절에 기술된 쿼리 블럭은 메모리에 한번만 올리기 때문에 쿼리에서 반복적으로 사용하
더라도 실제 데이터를 가져오는 작업은 한번만 발생

하지만 하나의 쿼리에서 동일한 서브쿼리가 반복적으로 사용 된다는 것은 쿼리를 잘못 작성할 가능성이
높다는 뜻이므로, WITH 절로 해결하기 보다는 쿼리를 다른 방식으로 작성할 수 없는지 먼저 고려 해볼 것을
추천.

회사의 DB를 다른 외부인에게 오픈할 수 없기 때문에 외부인에게 도움을 구하고자 할 때 테이블을 대신할
목적으로 많이 사용

사용방법 - 쿼리 블럭은 콤마(,)를 통해 여러개를 동시에 선언하는 것도 가능
WITH 쿼리블럭이름 AS (
     SELECT 쿼리
)
SELECT *
FROM 쿼리블럭이름;

-----------------------------------------------------------------------------------------------

[ 계층쿼리 ]

'202007' 달력 만들기
1. 2020년 7월의 일수 구하기
SELECT iw,
       MAX(DECODE(d, 1, dt, null)) sun, MAX(DECODE(d, 2, dt, null)) mon,
       MAX(DECODE(d, 3, dt, null)) tue, MAX(DECODE(d, 4, dt, null)) wed,
       MAX(DECODE(d, 5, dt, null)) thu, MAX(DECODE(d, 6, dt, null)) fri,
       MAX(DECODE(d, 7, dt, null)) sat
FROM
(SELECT TO_DATE(:yyyymm, 'YYYYMM') + (level - 1) dt,
       TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (level - 1), 'D') d,
       TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (level - 1), 'IW') iw 
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 'DD'))
GROUP BY DECODE(d, 1, iw + 1, iw)
ORDER BY DECODE(d, 1, iw + 1, iw);

-----------------------------------------------------------------------------------------------

[ 실습 calendar1 ]
1. dt컬럼을 이용하여 월 정보를 추출
2. 1번에서 추출된 월정보가 같은 행끼리 sales 컬럼의 합을 계산
3. 2번까지 계산된 결과를 인라인뷰로 생성
4. 3번에서 생성한 인라인뷰를 이용, 월별 컬럼을 6개 이용

SELECT 
       MIN(DECODE(a, 01, b)) JAN, MIN(DECODE(a, 02, b)) FEB, NVL(MIN(DECODE(a, 03, b)), 0) MAR,
       MIN(DECODE(a, 04, b)) APR, MIN(DECODE(a, 05, b)) MAY, MIN(DECODE(a, 06, b)) JUN
FROM
(SELECT TO_CHAR(dt, 'MM') a, SUM(sales) b
 FROM sales
 GROUP BY TO_CHAR(dt, 'MM'));

MAX, MIN, SUM ==> MIN 이 성능 가장 좋음

-----------------------------------------------------------------------------------------------

[ 과제 실습 calendar 0,2 ]

SELECT 
       MAX(DECODE(d, 1, dt, null)) sun, MAX(DECODE(d, 2, dt, null)) mon,
       MAX(DECODE(d, 3, dt, null)) tue, MAX(DECODE(d, 4, dt, null)) wed,
       MAX(DECODE(d, 5, dt, null)) thu, MAX(DECODE(d, 6, dt, null)) fri,
       MAX(DECODE(d, 7, dt, null)) sat
FROM
(SELECT TO_DATE(:yyyymm, 'YYYYMM') + (level - 1) dt,
       TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (level - 1), 'D') d,
       TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (level - 1), 'IW') iw 
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 'DD'))
GROUP BY DECODE(d, 1, iw + 1, iw)
ORDER BY DECODE(d, 1, iw + 1, iw);

SELECT DECODE(d, 1, iw + 1, iw) ddd, --COUNT(iw) t,
       MIN(DECODE(d, 1, dt)) sun, MIN(DECODE(d, 2, dt)) mon,
       MIN(DECODE(d, 3, dt)) tue, MIN(DECODE(d, 4, dt)) wed,
       MIN(DECODE(d, 5, dt)) thu, MIN(DECODE(d, 6, dt)) fri,
       MIN(DECODE(d, 7, dt)) sat
FROM
(SELECT TO_DATE('201905', 'YYYYMM') + (level - 1) dt,
       TO_CHAR(TO_DATE('201905', 'YYYYMM') + (level - 1), 'D') d,
       TO_CHAR(TO_DATE('201905', 'YYYYMM') + (level - 1), 'IW') iw
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE('201905', 'YYYYMM')), 'DD'))
GROUP BY DECODE(d, 1, iw + 1, iw)
ORDER BY DECODE(d, 1, iw + 1, iw);

SELECT iw,
       DECODE(d, 1, dt) sun, DECODE(d, 2, dt) mon,
       DECODE(d, 3, dt) tue, DECODE(d, 4, dt) wed,
       DECODE(d, 5, dt) thu, DECODE(d, 6, dt) fri,
       DECODE(d, 7, dt) sat
FROM
(SELECT TO_DATE('201905', 'YYYYMM') + (level - 1) dt,
       TO_CHAR(TO_DATE('201905', 'YYYYMM') + (level - 1), 'D') d,
       TO_CHAR(TO_DATE('201905', 'YYYYMM') + (level - 1), 'IW') iw
       
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE('201905', 'YYYYMM')), 'DD'));

iw 구하고, 해당 일자 구하고, 마지막 날짜 - 처음 날짜

--------------------------------------------------------------------------------------------------------------------

SELECT *
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE('201905', 'YYYYMM')), 'IW');

-----------------------------------------------------------------------------------------------------------

SELECT MIN(DECODE(d, 1, dt)) sun, MIN(DECODE(d, 2, dt)) mon, MIN(DECODE(d, 3, dt)) tue,
       MIN(DECODE(d, 4, dt)) wed, MIN(DECODE(d, 5, dt)) thu, MIN(DECODE(d, 6, dt)) fri,
       MIN(DECODE(d, 7, dt)) sat
FROM
(SELECT NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm-1, 'YYYYMM')) - 7, 1) + level - 1 dt, level,
       TO_CHAR(NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm-1, 'YYYYMM')) - 7, 1) + level - 1, 'IW') iw,
       TO_CHAR(NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm-1, 'YYYYMM')) - 7, 1) + level - 1, 'D') d
FROM dual
CONNECT BY LEVEL <= DECODE(TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 'D'), 7, LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 7))
                    - DECODE(TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM'), 'D'), 1, TO_DATE(:yyyymm, 'YYYYMM'), NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm-1, 'YYYYMM')) - 7, 1)) + 1)
GROUP BY DECODE(d, 1, iw + 1, iw)
ORDER BY DECODE(d, 1, iw + 1, iw);

NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm-1, 'YYYYMM')) - 7, 1)
-----------------------------------------------------------------------------------------------------------
SELECT DECODE(TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 'D'), 7, LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')) , 7))
FROM dual;

SELECT TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM'), 'D')
FROM dual;


SELECT NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm-1, 'YYYYMM')) - 7, 1) + level - 1 dt, level
FROM dual
CONNECT BY LEVEL <= DECODE(TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 'D'), 7, LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 7))
                                                                                                                        - NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm-1, 'YYYYMM')), 1) + 1;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT MIN(DECODE(d, 1, dt)) sun, MIN(DECODE(d, 2, dt)) mon, MIN(DECODE(d, 3, dt)) tue,
       MIN(DECODE(d, 4, dt)) wed, MIN(DECODE(d, 5, dt)) thu, MIN(DECODE(d, 6, dt)) fri,
       MIN(DECODE(d, 7, dt)) sat
FROM
(SELECT DECODE(TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM'), 'D'), 1, TO_DATE(:yyyymm, 'YYYYMM'), NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm-1, 'YYYYMM')) - 7, 1)) + level - 1 dt, level,
       TO_CHAR(DECODE(TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM'), 'D'), 1, TO_DATE(:yyyymm, 'YYYYMM'), NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm-1, 'YYYYMM')) - 7, 1)) + level - 1, 'IW') iw,
       TO_CHAR(DECODE(TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM'), 'D'), 1, TO_DATE(:yyyymm, 'YYYYMM'), NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm-1, 'YYYYMM')) - 7, 1)) + level - 1, 'D') d
FROM dual
CONNECT BY LEVEL <= DECODE(TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 'D'), 7, LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 7))
                    - DECODE(TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM'), 'D'), 1, TO_DATE(:yyyymm, 'YYYYMM'), NEXT_DAY(LAST_DAY(TO_DATE(:yyyymm-1, 'YYYYMM')) - 7, 1)) + 1)
GROUP BY DECODE(d, 1, iw + 1, iw)
ORDER BY sat;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT MIN(DECODE(d, 1, dt)) sun, MIN(DECODE(d, 2, dt)) mon,
       MIN(DECODE(d, 3, dt)) tue, MIN(DECODE(d, 4, dt)) wed,
       MIN(DECODE(d, 5, dt)) thu, MIN(DECODE(d, 6, dt)) fri,
       MIN(DECODE(d, 7, dt)) sat
FROM
(SELECT  TO_DATE(:yyyymm, 'yyyymm') - (TO_CHAR(TO_DATE(:yyyymm, 'yyyymm'), 'D') - 1) + level - 1 dt,
        TO_CHAR(TO_DATE(:yyyymm, 'yyyymm') - (TO_CHAR(TO_DATE(:yyyymm, 'yyyymm'), 'D') - 1) + level - 1, 'D') d,
        TO_CHAR(TO_DATE(:yyyymm, 'yyyymm') - (TO_CHAR(TO_DATE(:yyyymm, 'yyyymm'), 'D') - 1) + level - 1, 'IW') iw
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'yyyymm')), 'DD') + 7 - TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'yyyymm')), 'D') + TO_CHAR(TO_DATE(:yyyymm, 'yyyymm'), 'D') - 1)
GROUP BY DECODE(d, 1, iw + 1, iw)
ORDER BY sat;


SELECT TO_CHAR(TO_DATE(:yyyymm, 'yyyymm') - (TO_CHAR(TO_DATE(:yyyymm, 'yyyymm'), 'D') - 1) + (level - 1), 'IW') iw
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'yyyymm')), 'DD') + 7 - TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'yyyymm')), 'D') + TO_CHAR(TO_DATE(:yyyymm, 'yyyymm'), 'D') - 1;