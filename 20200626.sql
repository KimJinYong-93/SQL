WHERE 절에서 사용 가능한 연산자 : LIKE
사용용도 : 문자의 일부분으로 검색을 하고 싶을 때 사용
          ex : ename 컬럼의 값이 s로 시작하는 사원들을 조회
사용방법 : 컬럼 LIKE '패턴문자열'
마스킹 문자열 : 1. % : 문자가 없거나, 어떤 문자든 여러개의 문자열
                   'S%' : S로 시작하는 모든 문자열을
                          S, SS, SMITH
              2. _ : 어떤 문자든 딱 하나의 문자를 의미
                    'S_' : S로 시작하고 두번째 문자가 어떤 문자든 하나의 문자가 오는 2자리 
                          문자열
                    'S____' : S로 시작하고 문자열의 길이가 5글자인 문자열
                    
--emp테이블에서 ename 컬럼의 값이 S로 시작하는 사원들만 조회

SELECT *
FROM emp
WHERE ename LIKE 'S%';

SELECT *
FROM emp
WHERE ename LIKE '____S';

--member 테이블에서 회원의 성이 [신]씨인 사람의 mem_id, mem_name을 조회하는 쿼리를 작성하시오.

SELECT mem_id, mem_name
FROM member
WHERE mem_name LIKE '신%';

--member 테이블에서 회원의 이름에 글자[이]가 들어가는 모든 사람의 mem_id, mem_name을 조회하는
--쿼리를 작성하시오.

UPDATE member set mem_name= '쁜이'
WHERE mem_id = 'b001';

UPDATE member set mem_name= '신이환'
WHERE mem_id = 'c001';

SELECT mem_id, mem_name
FROM member
WHERE mem_name LIKE '%이%';

-------------------------------------------------------------------------------

NULL 비교 : =연산자로 비교 불가 ==> IS
NULL을 = 비교하여 조회

--comm 컬럼의 값이 null인 사원들만 조회
SELECT empno, ename, comm
FROM emp
WHERE comm = NULL;

--NULL값에 대한 비교는 = 이 아니라 IS 연산자를 사용 한다.
SELECT empno, ename, comm
FROM emp
WHERE comm IS NULL;

--emp 테이블에서 comm 값이 NULL이 아닌 데이터를 조회
AND, OR, NOT
SELECT empno, ename, comm
FROM emp
WHERE comm IS NOT NULL;

--논리연산
--논리연산자 : AND, OR, NOT
--AND : 참 거짓 판단식1 AND 참 거짓 판단식2 ==> 식 두개를 동시에 만족하는 행만 참
--    : 일반적으로 AND 조건이 많이 붙으면 조회되는 행의 수가 줄어든다
--OR : 참 거짓 판단식1 OR 참 거짓 판단식2 ==> 식 두개중에 하나라도 만족하면 
--NOT : 조건을 반대로 해석하는 부정형 연산
--     NOT IN : 포함되지 않는것
--     IS NOT NULL : NULL이 아닌것

SELECT *
FROM emp;

--emp 테이블에서 mgr 컬럼 값이 7698이면서 sal 컬럼의 값이 1000보다 큰 사원 조회
--2가지 조건을 동시에 만족하는 사원 리스트
SELECT *
FROM emp
WHERE mgr = 7698
  AND sal > 1000;
  
--mgr 값이 7698이거나 (5개) sal 값이 1000보다 크거나 두개의 조건을 하나라도 만족하는 행을 조회
SELECT *
FROM emp
WHERE mgr = 7698
  OR sal > 1000;
  
--emp 테이블에서 mgr 가 7698, 7839가 아닌 사원들을 조회
SELECT *
FROM emp
WHERE mgr NOT IN(7698, 7839);

--mgr 사번이 7698이 아니고, 7839가 아니고, NULL이 아닌 직원들을 조회
SELECT *
FROM emp
WHERE mgr NOT IN(7698, 7839, NULL);

SELECT *
FROM emp
WHERE mgr NOT IN(7698, 7839) AND mgr IS NOT NULL;

--mgr가 (7698, 7839, NULL)에 포함된다.
--mgr IN(7698, 7839, NULL); ==> mgr = 7698 OR mgr = 7839 OR mgr = NULL
--mgr NOT IN(7698, 7839, NULL); ==> mgr != 7698 AND mgr != 7839 AND mgr != NULL
--마지막에 mgr != NULL 값이 항상 false 라서 값이 나오지 않는다.

--mgr IN (7698, 7839) ==> OR
--mgr = 7698 OR mgr = 7839

--mgr NOT IN  (7698, 7839)
--!(mgr = 7698 OR mgr = 7839) ==> (mgr != 7698 AND mgr != 7839)
-- **** mgr 컬럼에 NULL값이 있을 경우 비교 연산으로 NULL 비교가 불가하기 때문에 NULL을 갖는
--      행은 무시가 된다.

--emp 테이블에서 job 이 SALESMAN 이고 입사일자가 1981년 6월 1일 이후인 직원의 정보를 다음과
--같이 조회 하세요. [WHERE7]

SELECT *
FROM emp
WHERE job = 'SALESMAN' 
  AND hiredate > TO_DATE('1981/06/01', 'YYYY/MM/DD');
--데이터는 대소문자를 가리기 때문에 'salesman' 이라고 치면 오류

--emp 테이블에서 부서번호가 10번이 아니고 입사일자가 1981년 6월 1일 이후인 직원의 정보를
--다음과 같이 조회 하세요(IN, NOT IN 연산자 사용 금지) [WHERE8]
SELECT *
FROM emp
WHERE deptno != 10 
  AND hiredate > TO_DATE('1981/06/01', 'YYYY/MM/DD');
  
--[WHERE9] WHERE8과 동일 조건을 NOT IN 사용

SELECT *
FROM emp
WHERE deptno NOT IN (10) 
  AND hiredate > TO_DATE('1981/06/01', 'YYYY/MM/DD');
  
--emp 테이블에서 부서번호가 10번이 아니고 입사일자가 1981년 6월 1일 이후인 직원의 정보를
--다음과 같이 조회 하세요. (부서는 10,20,30 만 있다고 가정하고 IN 연산자를 사용) [WHERE10]
SELECT *
FROM emp
WHERE deptno IN(20, 30) 
  AND hiredate > TO_DATE('1981/06/01', 'YYYY/MM/DD');
  
--emp 테이블에서 job이 SALESMAN 이거나 입사일자가 1981년 6월 1일 이후인 직원의 정보를 
--다음과 같이 조회 하세요. [WHERE11]
SELECT *
FROM emp
WHERE job = 'SALESMAN'
   OR hiredate > TO_DATE('1981/06/01', 'YYYY/MM/DD');
   
--emp 테이블에서 job이 SALESMAN이거나 사워번호가 78로 시작하는 직원의 정보를 다음과 같이
--조회 하세요. [WHERE12]
SELECT *
FROM emp
WHERE job = 'SALESMAN' OR empno LIKE '78%';
--형변환 : 명시적, 묵시적

--emp 테이블에서 job이 SALESMAN이거나 사워번호가 78로 시작하는 직원의 정보를 다음과 같이
--조회 하세요. (LIKE 연산자를 사용하지 마세요.) [WHERE13]
SELECT *
FROM emp
WHERE job = 'SALESMAN' OR empno = 78 OR (empno >= 780 AND empno <= 789) 
   OR (empno >= 7800 AND empno <= 7899); --BETWEEN 으로도 가능
   
--연산자 우선순위
--+, -, *, /
--*, / > +, -
--3 + 5 * 7 = 38
--일반 수학과 마찬가지로 괄호()를 통해 우선순위를 변경할 수 있다.

--emp 테이블에서
--1. job이 SALESMAN 이거나
--2. 사원번호가 78로 시작하면서 입사일자가 1981년 6월 1일 이후인 직원의 정보를 다음과 같이
--조회 하세요. (1번 조건 또는 2번 조건을 만족 하는 직원) [WHERE14]
SELECT *
FROM emp
WHERE (job = 'SALESMAN') OR ((hiredate > TO_DATE('1981/06/01', 'YYYY/MM/DD')) 
  AND (empno BETWEEN 78 AND 78
   OR empno BETWEEN 780 AND 789
   OR empno BETWEEN 7800 AND 7899));

--SQL 작성순서(꼭 그렇지는 않다)      ORACLE에서 실행하는 순서   
--1. SELECT                                3순위
--2. FROM                                  1순위
--3. WHERE                                 2순위
--4. ORDER BY                              4순위

--정렬
--RDBMS는 집합적인 사상을 따른다
--집합에는 순서가 없다 {1,3,5} == {3,5,1}
--집합에는 중복이 없다 {1,3,5,1} == {3,5,1}

--정렬 방법 : ORDER BY 절을 통해 정렬 기준 컬럼을 명시
--           컬럼뒤에 [ASC | DESC] 을 기술하여 오름차순, 내림차순을 지정할 수 있다

--1. ORDER BY 컬럼
--2. ORDER BY 별칭
--3. ORDER BY SELECT 절에 나열된 컬럼의 인덱스 번호

SELECT *
FROM emp
ORDER BY 컬럼 | 별칭 | 나열된 컬럼의 인덱스 번호 [ASC | DESC];

SELECT *
FROM emp
ORDER BY ename;


SELECT *
FROM emp
ORDER BY ename ASC; --오름차순

SELECT *
FROM emp
ORDER BY ename DESC;

SELECT *
FROM emp
ORDER BY ename DESC, mgr; --mgr 은 두번째 기술 조건으로 같은 순위가 있을때 조건을 줄 수 있다.

--별칭으로 ORDER BY 
SELECT empno, ename, sal, sal*12 salary
FROM emp
ORDER BY salary;

--SELECT 절에 기술된 컬럼순서(인덱스)로 정렬
SELECT empno, ename, sal, sal*12 salary
FROM emp
ORDER BY 4; --4번째 컬럼인 sal*12 salary 로 정렬됨. ==> 데이터 추가시 다른 데이터 추출

--dept 테이블의 모든 정보를 부서이름으로 오름차순 정렬로 조회되도록 쿼리를 작성하세요.
--dept 테이블의 모든 정보를 부서위치로 내림차순 정렬로 조회되도록 쿼리를 작성하세요. [ORDERBY1]
SELECT *
FROM dept
ORDER BY dname ASC;

SELECT *
FROM dept
ORDER BY loc DESC;

--emp 테이블에서 상여(comm) 정보가 있는 사람들만 조회하고, 상여(comm)를 많이 받는 사람이 먼저
--조회되도록 하고, 상여가 같을 경우 사번으로 내림차순 정렬하세요.(상여가 0인 사람은 상여가 없는
--것으로 간주) [ORDERBY2]
SELECT *
FROM emp
WHERE comm > 0
ORDER BY comm DESC, empno;



--<과제>
--[ORDERBY3,4]

SELECT *
FROM emp
WHERE mgr > 0
ORDER BY job ASC, empno DESC;

SELECT *
FROM emp
WHERE deptno IN (10, 30) AND sal > 1500
ORDER BY ename DESC;


