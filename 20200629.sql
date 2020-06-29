--ROWNUM : SELECT 순서대호 행 번호를 부여해주는 가상 컬럼
--특징 : WHERE 절에서 사용 가능
--    *** 사용할 수 있는 형태가 정해져 있음 ***
--      WHERE ROWNUM = 1;                ROWNUM이 1일 때
--      WHERE ROWNUM <= N;              ROWNUM이 N보다 작거나 같은 경우, 작은 경우
--      WHERE ROWNUM BETWEEN 1 AND N;   ROWNUM이 1보다 크거나 같고 N보다 작거나 같은 경우
--              ==> ROWNUM은 1부터 순차적으로 읽는 환경에서만 사용이 가능
--    ***** 안되는 경우 *****
--      WHERE ROWNUM = 2;
--      WHERE ROWNUM >= 2;
--ROWNUM 사용 용도 : 페이징 처리
--페이징 처리 : 네이버 카페에서 게시글 리스트를 한 화면에 제한적인 갯수로 조회(100개)
--            카페에 전체 게시글 수는 굉장히 많음 ==> 한 화면에 못 보여줌
--              1. 웹브라우저가 버벅임, 2. 사용자의 사용서이 굉장히 불편
--              ==> 한 페이지당 건수를 정해놓고 해당 건수만큼만 조회해서 화면에 보여준다.

--WHERE절에서 사용할 수 있는 형태
SELECT ROWNUM, empno, ename
FROM emp
WHERE ROWNUM = 1;

SELECT ROWNUM, empno, ename
FROM emp
WHERE ROWNUM <= 10;

--WHERE절에서 사용할 수 없는 형태
SELECT ROWNUM, empno, ename
FROM emp
WHERE ROWNUM >= 10;

--ROWNUM과 ORDER BY
--SELECT SQL의 실행순서 : FROM => WHERE => SELECT => ORDER BY

SELECT ROWNUM, empno, ename
FROM emp
ORDER BY ename;
-- ==> SELECT 에서 ROWNUM 이 먼저 적용된 상태에서 한 번 더 ROWNUM 이 적용되서 뒤죽박죽

--ROWNUM의 결과를 정렬 이후에 반영 하고 싶은 경우 ==> IN-LINE VIEW 사용
--VIEW : SQL - DBMS에 저장되어있는 SQL
--IN-LINE : 직접 기술 했다, 어딘가 저장을 한게 아니라 그 자리에 직접 기술

ROWNUM, empno, ename

--SELECT 절에 *만 단독으로 사용하지 않고 콤마를 통해 다른 임의 컬럼이나 expression을 표기한 경우
-- * 앞에 어떤 테이블(뷰)에서 온 것인지 한정자(테이블 이름, view 이름)를 붙여줘야 한다.

--table, view 별칭 : table이나 view에도 SELECT절의 컬럼처럼 별칭을 부여할 수 있다.
--                  단, SELECT 절처럼 AS 키워드는 사용하지 않는다.
--                  EX : FROM emp e
--                       FROM (SELECT empno, ename
--                             FROM emp
--                             ORDER BY ename) v_emp;

SELECT emp.*
FROM emp;


SELECT ROWNUM, a.*
FROM (SELECT empno, ename
      FROM emp
      ORDER BY ename) a;
--  ==> () 를 FROM 절이라고 생각하고 사용(SELECT 구문을 하나의 테이블로 생각하고 사용)
--요구사항 : 1페이지당 10건의 사원 리스트가 보여야된다
--페이지번호, 페이지당 사이즈
--1 page : 1~10
--2 page : 11~20
--3 page : 21~30
--.
--.
--.
--n page : 10(n-1)+1 ~ 10n
--      ==> (n-1) * pageSize + 1 ~ n * pageSize

--페이징 처리 쿼리 1page
SELECT ROWNUM, a.*
FROM (SELECT empno, ename
      FROM emp
      ORDER BY ename) a
WHERE ROWNUM BETWEEN 1 AND 10;

--페이징 처리 쿼리 2page
SELECT ROWNUM, a.*
FROM (SELECT empno, ename
      FROM emp
      ORDER BY ename) a
WHERE ROWNUM BETWEEN 11 AND 20;
--ROWNUM의 특성으로 1번부터 읽지 않는 형태이기 때문에 정상적으로 동작하지 않는다.
--ROWNUM의 값으려 별칭을 통해 새로운 컬럼으로 만들고 해당 SELECT SQL을 IN-LINE VIEW로 만들어서 
--외부에서 ROWNUM에 부여한 별칭을 통해 페이지 처리를 한다.

--페이징 처리 쿼리 2page
SELECT *
FROM (SELECT ROWNUM rn, a.*
      FROM (SELECT empno, ename
            FROM emp
            ORDER BY ename) a)
WHERE rn BETWEEN 11 AND 20;

--SQL 바인딩 변수 : java 변수
--페이지 번호 : page
--페이지 사이즈 : pageSize
--SQL 바인딩 변수 표기 ==> :변수명 ==> :page, :pageSize

--바인딩 변수 적용 (:page-1) * :pageSize + 1 ~ :page * :pageSize
SELECT *
FROM (SELECT ROWNUM rn, a.*
      FROM (SELECT empno, ename
            FROM emp
            ORDER BY ename) a)
WHERE rn BETWEEN (:page-1) * :pageSize + 1 AND :page * :pageSize;
--      ==> 바인드 값 입력

--FUNCTION : 입력을 받아들여 특정 로직을 수행후 결과 값을 반환하는 객체
--오라클에서의 함수 구분 : 입력되는 행의 수에 따라
--1. Single row funtion
--      하나의 행이 입력되서 결과로 하나의 행이 나온다.
--2. Multi row function 
--      여러개의 행이 입력되서 결과로 하나의 행이 나온다.

--dual 테이블 : oracle의 sys 계정에 존재하는 하나의 행, 하나의 컬럼(dummy)을 갖는 테이블. 
--             누구나 사용할 수 있도록 권한이 개방됨.
--dual 테이블 용도
--1. 함수 실행 (테스트)
--2. 시퀀스 실행
--3. merge 구문
--4. 데이터 복제***
--* LENGTH 함수 테스트
SELECT LENGTH('TEST')
FROM dual;

SELECT LENGTH('TEST'),LENGTH('TEST'), emp.*
FROM emp;

--문자열 관련 함수 : 설명은 PT 참고(억지로 외우지는 말자)
SELECT CONCAT('Hello', CONCAT(', ', 'World')) concat,
       SUBSTR('Hello, World', 1, 5) substr,
       LENGTH('Hello, World') length,
       INSTR('Hello, World', 'o') instr,
       INSTR('Hello, World', 'o', INSTR('Hello, World', 'o')+1) instr,
       LPAD('Hello, World', 15, ' ') lpad,
       RPAD('Hello, World', 15, ' ') rpad,
       REPLACE('Hello, World', 'o', 'p') repalce,
       TRIM('  Hello, World ') trim,
       TRIM('d' FROM 'Hello, World') trim,
       LOWER('Hello, World') lower,
       UPPER('Hello, World') upper,
       INITCAP('hello, world') initcap
FROM dual;

--함수는 WHERE 절에서도 사용 가능
--사원 이름이 smith인 사람
SELECT *
FROM emp
WHERE ename = UPPER('smith'); --UPPER를 쓰지 않으면 이름을 소문자로 작성해서 나오지 않음.

SELECT *
FROM emp
WHERE LOWER(ename) = 'smith';

--위 두개의 쿼리중에서 하지 말아야 할 형태
--두번째 쿼리는 14번을 실행해 봐야 소문자로 바뀌고 나서 비교를함
--      ==>좌변을 가공하는 형태 (좌변 - 테이블 컬럼을 의미)
--첫번째 쿼리는 고정된 'smith' 한 번만 적용하면 찾을 수 있음.


--오라클 숫자 관련 함수
--ROUND(숫자, 반올림 기준자리) : 반올림 함수
--TRUNC(숫자, 내림 기준자리) : 내림 함수
--MOD(피제수, 제수) : 나머지 값을 구하는 함수

SELECT ROUND(105.54, 1) round, -- 두번째 인자의 자리까지 반올림
       ROUND(105.55, 1) round2,
       ROUND(105.55, 0) round3,
       ROUND(105.55) round4, --두번째 인자 빼면 0을 넣은 것과 같은 결과
       ROUND(105.55, -1) round5 --값이 음수일때는 해당 자리
FROM dual;
--  1  0  5  .  5  4 
-- -3 -2 -1  0  1  2   ==> 자릿수

SELECT TRUNC(105.54, 1) TRUNC, 
       TRUNC(105.55, 1) TRUNC,
       TRUNC(105.55, 0) TRUNC3,
       TRUNC(105.55, -1) TRUNC4 
FROM dual;

--sal을 1000으로 나눴을때의 나머지 ==> mod 함수, 별도의 연산자는 없다.
--몫 : quotient , 나머지 : reminder
SELECT ename, TRUNC(sal/1000, 0) 몫, MOD(sal, 1000) reminder
FROM emp;

--날짜 관련 함수
--SYSDATE : 오라클에서 제공해주는 특수함수
--          1. 인자가 없음
--          2. 오라클이 설치된 서버의 현재 년, 월, 일, 시, 분, 초 정보를 반환해주는 함수

SELECT SYSDATE
FROM dual;

--날짜타입 +- 정수 : 정수를 일자 취급, 정수만큼 미래, 혹은 과거 날짜의 데이트 값을 반환
--ex : 오늘 날짜에서 하루 더한 미래 날짜 값은?
SELECT SYSDATE + 1
FROM dual;

--ex : 현재 날짜에서 3시간 뒤 데이트를 구하려면?
SELECT SYSDATE + 3/24
FROM dual;
--1분 : 1/24/60
--30분 후
SELECT SYSDATE + 30/24/60
FROM dual;

--데이트 표현하는 방법
--1. 데이트 리터럴 : NLS_SESSION_PARAMETER 설정에 따르기 때문에 DBMS 환경마다 다르게 인식될 수 있음
--2. TO_DATE : 문자열을 날짜로 변경해주는 함수

--실습1
--1. 2020년 12월 31일을 date 형으로 표현
--2. 2020년 12월 31일을 date 형으로 표현하고 5일 이전 날짜
--3. 현재 날짜
--4. 현재 날짜에서 3일 전 값
SELECT SYSDATE now, SYSDATE -3 now_before,
       TO_DATE('2020/12/31', 'YYYY/MM/DD') lastday,
       TO_DATE('2020/12/31', 'YYYY/MM/DD') - 5 lastday_before
FROM dual;

--문자열 ==> 데이트
--  TO_DATE(날짜 문자열, 날짜 문자열의 패턴);
--데이트 ==> 문자열 (보여주고 싶은 형식을 지정할 때)
--  TO_CHAR(데이트 값, 표현하고싶은 문자열 패턴)

--SYSDATE 현재 날짜를 년도4자리-월2자리-일2자리
SELECT SYSDATE, TO_CHAR(SYSDATE, 'YYYY-MM-DD'),
       TO_CHAR(SYSDATE, 'D'), --주간 일자는 일요일이 기준
       TO_CHAR(SYSDATE, 'IW') 
FROM dual;
--날짜 포맷 : PT 참고

SELECT ename, hiredate, TO_CHAR(hiredate, 'YYYY/MM/DD HH24:MI:SS') h1,
       TO_CHAR(hiredate + 1, 'YYYY/MM/DD HH24:MI:SS') h2,
       TO_CHAR(hiredate + 1/24, 'YYYY/MM/DD HH24:MI:SS') h3
FROM emp;

--실습2 오늘 날짜를 다음과 같은 포맷으로 조회하는 쿼리를 작성하시오.
--1. 년-월-일
--2. 년-월-일 시간24-분-초
--3. 일-월-년
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD') dt_dash,
       TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24-MI-SS') dt_dash_with_time,
       TO_CHAR(SYSDATE, 'DD-MM-YYYY') dt_dd_mm_yyyy
FROM dual;




