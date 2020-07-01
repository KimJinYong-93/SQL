--날짜관련 오라클 내장함수
--내장함수 : 탑재가 되어있음. 오라클에서 제공해주는 함수(많이 사용하니까, 개발자가 별도로 개발하지 않도록)

-- MONTHS_BETWEEN(date1, date2) : 두 날짜 사이의 개월수를 반환(일수가 다르면 소수점으로
--                                계산된다. (활용도:*)
-- ADD_MONTHS(date1, NUMBER) : DATE1 날짜에 NUMBER 만큼의 개월수를 더하고, 뺀 날짜를 리턴 
--                             (활용도:****)
-- NEXT_DAY(date1, 주간요일(1~7)) : date1 이후에 등장하는 첫번째 주간요일의 날짜 반환 (활용도:***)
--                            ex : 20200630, 6 ==> 20200703 
-- LAST_DAY(date1) : date1 날짜가 속한 월의 마지막 날짜를 반환 (활용도:***)
--              ex : 20200605 ==> 20200630 // 모든 달의 첫번째 날짜는 1일로 정해져 있음
--                                            하지만 달의 마지막 날짜는 다른 경우가 있다.(ex : 윤년)

--MONTHS_BETWEEN
SELECT ename, TO_CHAR(hiredate, 'YYYY-MM-DD') hiredate, 
       MONTHS_BETWEEN(SYSDATE, hiredate)
FROM emp;

--ADD_MONTHS
SELECT ADD_MONTHS(SYSDATE, 5) aft5,
       ADD_MONTHS(SYSDATE, -5) bef5
FROM dual;

--NEXT_DAY : 해당 날짜 이후에 등장하는 첫번째 주간요일의 날짜
SELECT NEXT_DAY(SYSDATE, 7) 
FROM dual;

--LAST_DAY : 해당 일자가 속한 월의 마지막 일자를 반환
--SYSDATE : 2020/06/30 실습 다일의 날짜가 월의 마지막이라 SYSDATE 대신 임의의 날짜 문자열로 테스트
--          ==> 2020/06/05
SELECT LAST_DAY(TO_DATE('2020/06/05', 'YYYY/MM/DD'))
FROM dual;

--FIRST_DAY 는 모든 월의 첫 번째 날짜는 동일하기 때문에 없음.
--FIRST_DAY 를 직접 SQL로 구현
--SYSDATE : 20200630 ==> 20200601
--1. SYSDATE 를 문자로 변경하는데 포맷은 YYYYMM
--2. 1번의 결과에다가 문자열 결합을 통해 '01' 문자를 뒤에 붙여 준다.
--  ==> YYYYMMDD
--3. 2번의 결과를 날짜 타입으로 변경

SELECT TO_DATE(CONCAT(TO_CHAR(SYSDATE, 'YYYYMM'), '01'), 'YYYYMMDD') FIRST_DAY
       --CONCAT(TO_CHAR(SYSDATE, 'YYYYMM'), '01')
       --TO_CHAR(SYSDATE, 'YYYYMM')
FROM dual;

--실습3
--파라미터로 yyyymm형식의 문자열을 사용 하여 (ex : yyyymm = 201912) 해당 년월에 해당하는 일자 
--수를 구해보세요.
--201912 ==> 31, 201911 ==> 30, 201602 ==> 29
SELECT '201911' param, TO_CHAR(LAST_DAY(TO_DATE('201911', 'YYYYMM')), 'DD') DT
FROM dual;

SELECT :param param, TO_CHAR(LAST_DAY(TO_DATE(:param, 'YYYYMM')), 'DD') DT
FROM dual;

--실행계획 : DBMS가 요청받은 SQL을 처리하기 위해 세운 절차
--        : SQL 자체에는 로직이 없다. (어떻게 처리 해라?? 가 없다. JAVA랑 다른점)
--실행계획 보는 방법 : 
--1. 실행계획을 생성
--      EXPLAIN PLAN FOR
--      실행계획을 보고자 하는 SQL;
--2. 실행계획을 보는 단계
--      SELECT *
--      FROM TABLE(dbms_xplan.display);     dbms_xplan 은 display 라는 것을 보여주는 패키지
--                                          display 에서 리턴하는 값을 TABLE 처럼 보여주는것
--empno 컬럼은 NUMBER 타입이지만 형변환이 어떻게 일어났는지 확인하기 위하여 의도적으로 문자열 상수 
--비교를 진행
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = '7369';

SELECT *
FROM TABLE(dbms_xplan.display);

--실행계획을 읽는 방법 : **** 
 --1. 위에서 아래로
 --2. 단 자식 노드가 있으면 자식 노드 부터 읽는다. (자식노드 : 들여쓰기가 된 노드)

Plan hash value: 3956160932
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    87 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP  |     1 |    87 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------
 
Predicate Information (identified by operation id):   --특수 정보 표시(위에서 * 있는 것의 정보)
---------------------------------------------------
 
   1 - filter("EMPNO"=7369) --묵시적 형변환이 일어남. ==> 우리는 문자로 입력했지만 숫자로 형변환됨.
 
Note
-----
   - dynamic sampling used for this statement (level=2)

---------------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE TO_CHAR(empno) = '7369';

SELECT *
FROM TABLE(dbms_xplan.display);


Plan hash value: 3956160932
 
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    87 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP  |     1 |    87 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter(TO_CHAR("EMPNO")='7369')  ==> 비효율이 더 생김
 
Note
-----
   - dynamic sampling used for this statement (level=2)
   
-------------------------------------------------------------------------------------
   
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = 7300 + '69';

SELECT *
FROM TABLE(dbms_xplan.display);

Plan hash value: 3956160932
 
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    87 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP  |     1 |    87 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("EMPNO"=7369) ==> 숫자취급됨
 
Note
-----
   - dynamic sampling used for this statement (level=2)
   
-------------------------------------------------------------------------------------


6,000,000 <===> 6000000
--국제화 : i18n
-- 날짜 국가별로 형식이 다르다.
--      한국 : yyyy-mm-dd
--      미국 : mm-dd-yyyy

-- 숫자
--      한국 : 9,000,000.00
--      독일 : 9.000.000,00

-- sal(NUMBER) 컬럼의 값을 문자열 포맷팅 적용
SELECT ename, sal, TO_CHAR(sal, 'L9,999.00') fm_sal
FROM emp;

SELECT ename, sal, TO_NUMBER(TO_CHAR(sal, 'L9,999.00'), 'L9,999.00') fm_sal
FROM emp;

--NULL과 관련된 함수 : NULL값을 다른값으로 치환 하거나, 혹은 강제로 NULL을 만드는 것
--1. NVL(expr1, expr2)
--      if(expr1 == null)
--          expr2를 반환
--      else
--          expr1을 반환;
SELECT empno, sal, comm, NVL(comm, 0), sal + comm, sal + NVL(comm, 0)
FROM emp;
--2. NVL2(expr1, expr2, expr3)
--      if(expr1 != null)
--          expr2를 반환
--      else
--          expr3을 반환;
SELECT empno, sal, comm, NVL2(comm, comm ,0), sal + comm, sal + NVL2(comm, comm ,0),
       NVL2(comm, sal + comm ,sal)
FROM emp;
--3. NULLIF(expr1, expr2) : NULL값을 생성하는 목적
--      if(expr1 == expr2)
--          null을 반환
--      else
--          expr1을 반환
SELECT ename, sal, comm, NULLIF(sal, 3000)
FROM emp;
--4. COALESCE(expr1, expr2,.....) : 인자중에 가장 처음으로 null값이 아닌 값을 갖는 인자를 반환
--      COALESCE(NULL, NULL, 30, NULL, 50) ==> 30
--      if(expr1 != null)
--          expr1을 반환
--      else
--          COALESCE(expr2,....)    ==> 재귀함수개념
SELECT COALESCE(NULL, NULL, 30, NULL, 50)
FROM dual;

--NULL처리 실습
--emp테이블에 14명의 사원이 존재, 한 명을 추가(INSERT)
INSERT INTO emp (empno, ename, hiredate) VALUES (9999, 'brown', NULL);

--조회컬럼 : ename, mgr, mgr컬럼 값이 NULL이면 111로 치환한값 - NULL이 아니면 mgr 컬럼값,
--          hiredate, hiredate가 NULL이면 SYSDATE로 표기 - NULL이 아니면 hiredate 컬럼값

SELECT ename, mgr, NVL(mgr, 111), hiredate, NVL(hiredate, SYSDATE)
FROM emp;

--실습4
--nvl, nvl2, coalesce 사용
SELECT empno, ename, mgr, NVL(mgr, 9999) mgr_n, NVL2(mgr, mgr, 9999) mgr_n_1, 
       COALESCE(mgr, 9999) mgr_n_2
FROM emp;

--실습5
SELECT userid, usernm, reg_dt, NVL(reg_dt, SYSDATE) n_reg_dt
FROM users
WHERE userid != 'brown';

SELECT ROUND((6/28) * 100, 2) || '%'
FROM dual;

--   ==> 컬럼 하나로 표현된다.
--SQL 조건문
CASE 
    WHEN 조건문(참 거짓을 판단할 수 있는 문장) THEN 반환값
    WHEN 조건문(참 거짓을 판단할 수 있는 문장) THEN 반환값2
    WHEN 조건문(참 거짓을 판단할 수 있는 문장) THEN 반환값3
    ELSE 모든 WHEN절을 만족시키지 못할 때 반환할 기본값
END 

emp테이블에 저장된 job 컬럼의 값을 기준으로 급여(sal)를 인상시키려고 한다. sal컬럼과 함께 
인상된 sal 컬럼의 값을 비교 하고 싶은 상황
급여 인상 기준
job이 SALESMAN : sal * 1.05
job이 MANAGER : sal * 1.1
job이 PRESIDENT : sal * 1.2
나머지 기타 직군은 sal로 유지

SELECT ename, job, sal,
       CASE 
            WHEN job = 'SALESMAN' THEN sal * 1.05
            WHEN job = 'MANAGER' THEN sal * 1.1
            WHEN job = 'PRESIDENT' THEN sal * 1.2
            ELSE sal
       END inc_sal
FROM emp;

--실습 cond1
SELECT empno, ename,
       CASE 
            WHEN deptno = 10 THEN UPPER('accounting')
            WHEN deptno = 20 THEN UPPER('research')
            WHEN deptno = 30 THEN UPPER('sales')
            WHEN deptno = 40 THEN UPPER('operations')
            ELSE UPPER('ddit')
        END dname          
FROM emp;

SELECT empno, job, sal,
       DECODE(deptno, 10, 'ACCOUNTING',
                      20, 'RESEARCH',
                      30, 'SALES',
                      40, 'OPERATIONS') dname
FROM emp;