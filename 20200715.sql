오라클 객체(object)
 table - 데이터 저장 공간
    ddl 생성, 수정, 삭제
 view - sql(쿼리다) 논리적인 데이터 정의, 실체가 없다
        view를 구성하는 테이블의 데이터가 변경되면 view 결과도 달라지더라
 sequence - 중복되지 않는 정수값을 반환해주는 객체
            유일한 값이 필요할 때 사용할 수 있는 객체
            nextval, currval
 index - 테이블의 일부 컬럼을 기준으로 미리 정렬해 놓은 데이터
         ==> 테이블 없이 단독적으로 생성 불가, 특정 테이블에 종속
             table 삭제를 하면 관련 인덱스도 같이 삭제

-----------------------------------------------------------------------------------------------

DB 구조에서 중요한 전제조건
1. DB에서 I/O의 기준은 행단위가 아니라 block 단위
   한 건의 데이터를 조회하더라도, 해당 행이 존재하는 block 전체를 읽는다.
   
데이터 접근 방식
 1. table full access
    multi block io ==> 읽어야 할 블럭 여러개를 한번에 읽어 들이는 방식(일반적으로 8~16 block)
    사용자가 원하는 데이터의 결과가 table의 모든 데이터를 다 읽어야 처리가 가능한 경우
    ==> 인덱스 보다 여러 블럭을 한번에 많이 조회하는 table full access 방식이 유리할 수 있다.
    ex - 전제조건은 mgr, sal, comm 컬럼으로 인덱스가 없을 때
         mgr, sal, comm 정보를 table 에서만 획득이 가능할 때
    SELECT * COUNT(mgr), SUM(sal), SUM(comm), AVG(sal)
    FROM emp;
 2. index 접근, index 접근 후 table access
    single block io ==> 읽어야 할 행이 있는 데이터 block 만 읽어서 처리하는 방식
    소수의 몇건의 데이터를 사용자가 조회할 경우, 그리고 조건에 맞는 인덱스가 존재할 경우 빠르게 응답을
    받을 수 있다.
   
    하지만, single block io가 빈번하게 일어나면 multi block io 보다 오히려 느리다.

2. extent, 공간 할당 기준 --지금 수업 내용과 관련 없다

-----------------------------------------------------------------------------------------------

현재 상태
인덱스 : IDX_NU_emp_01 (empno)

emp 테이블의 job 컬럼을 기준으로 2번째 NON-UNIQUE 인덱스 생성
CREATE INDEX idx_nu_emp_02 ON emp (job);

현재 상태
인덱스 : idx_nu_emp_01 (empno), idx_nu_emp_02 (job)
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job = 'MANAGER'
  AND ename LIKE 'C%';

SELECT *
FROM TABLE(dbms_xplan.display);

Plan hash value: 3525611128
 
---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    36 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_02 |     3 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 2 - 1 - 0
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("ENAME" LIKE 'C%')
   2 - access("JOB"='MANAGER')

인덱스 추가 생성
emp 테이블의 job, ename 컬럼으로 복합 non-unique index 생성
idx_nu_emp_03
CREATE INDEX idx_nu_emp_03 ON emp (job, ename);

현재 상태
인덱스 : idx_nu_emp_01 (empno), idx_nu_emp_02 (job), idx_nu_emp_03 (job, ename)

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job = 'MANAGER'
  AND ename LIKE 'C%';

SELECT *
FROM TABLE(dbms_xplan.display);  

Plan hash value: 1746703018
 
---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    36 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_03 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("JOB"='MANAGER' AND "ENAME" LIKE 'C%')
       filter("ENAME" LIKE 'C%')



SELECT job, ename, ROWID
FROM emp
ORDER BY job, ename;

위에 쿼리와 변경된 부분은 LIKE 패턴이 변경
LIKE 'C%' ==> LIKE '%C'

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job = 'MANAGER'
  AND ename LIKE '%C';
  
SELECT *
FROM TABLE(dbms_xplan.display);  

Plan hash value: 1746703018
 
---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    36 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_03 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("JOB"='MANAGER')
       filter("ENAME" LIKE '%C' AND "ENAME" IS NOT NULL)
       

인덱스 추가
emp 테이블에 ename, job 컬럼을 기준으로 non-unique 인덱스 생성(inx_nu_emp_04)
CREATE INDEX inx_nu_emp_04 ON emp (ename, job);

현재 상태
인덱스 : idx_nu_emp_01 (empno)
        idx_nu_emp_02 (job)
        idx_nu_emp_03 (job, ename) ==> 삭제
        idx_nu_emp_04 (ename, job) - 복합 컬럼의 인덱스의 컬럼순서가 미치는 영향

DROP INDEX idx_nu_emp_03;

SELECT ename, job, rowid
FROM emp
ORDER BY ename, job;


EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job = 'MANAGER'
  AND ename LIKE 'C%';
  
SELECT *
FROM TABLE(dbms_xplan.display);

---------------------------------------------------------------------------------------------

조인에서의 인덱스 활용
emp : pk_emp, fk_emp_dept 생성

DESC emp;

ALTER TABLE emp ADD CONSTRAINT pk_emp PRIMARY KEY (empno);
ALTER TABLE dept ADD CONSTRAINT pk_dept PRIMARY KEY (deptno);
ALTER TABLE emp ADD CONSTRAINT fk_emp_dept FOREIGN KEY (deptno) REFERENCES dept (deptno);

emp : pk_emp (empno), idx_...
dept : pk_dept (deptno)

접근방식 : emp 1. table full access, 2. 인덱스 * 4 : 방법 5가지 
          dept 1. table full access, 2. 인덱스 * 1 : 방법 2가지 
          가능한 경우의 수가 10가지
          방향성 emp, dept를 먼저 처리할 지 ==> 20가지


EXPLAIN PLAN FOR
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno
  AND emp.empno = 7788; -- 조건을 제한하므로써(여기서는 상수값으로) 인덱스가 찾아갈 경로를 줄인다.

SELECT *
FROM TABLE(dbms_xplan.display);

Plan hash value: 999219729
 
-----------------------------------------------------------------------------------------------
| Id  | Operation                     | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |               |     1 |    54 |     2   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                 |               |       |       |            |          |
|   2 |   NESTED LOOPS (반복문이라 생각)|               |     1 |    54 |     2   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     1   (0)| 00:00:01 |
|*  4 |     INDEX RANGE SCAN          | IDX_NU_EMP_01 |     1 |       |     0   (0)| 00:00:01 |
|*  5 |    INDEX UNIQUE SCAN          | PK_DEPT       |     1 |       |     0   (0)| 00:00:01 |
|   6 |   TABLE ACCESS BY INDEX ROWID | DEPT          |     8 |   144 |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------
 4 - 3 - 5 - 2 - 6 - 1 - 0
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - filter("EMP"."DEPTNO" IS NOT NULL)
   4 - access("EMP"."EMPNO"=7788)
   5 - access("EMP"."DEPTNO"="DEPT"."DEPTNO")


--위의 쿼리에서 상수값 조건 삭제
EXPLAIN PLAN FOR
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno;

SELECT *
FROM TABLE(dbms_xplan.display);
 
Plan hash value: 844388907
 
----------------------------------------------------------------------------------------
| Id  | Operation                    | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |         |    13 |   702 |     6  (17)| 00:00:01 |
|   1 |  MERGE JOIN                  |         |    13 |   702 |     6  (17)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| DEPT    |     8 |   144 |     2   (0)| 00:00:01 |
|   3 |    INDEX FULL SCAN           | PK_DEPT |     8 |       |     1   (0)| 00:00:01 |
|*  4 |   SORT JOIN                  |         |    14 |   504 |     4  (25)| 00:00:01 |
|*  5 |    TABLE ACCESS FULL         | EMP     |    14 |   504 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------------------
 3 - 2 - 5 - 4 - 1 - 0
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access("EMP"."DEPTNO"="DEPT"."DEPTNO")
       filter("EMP"."DEPTNO"="DEPT"."DEPTNO")
   5 - filter("EMP"."DEPTNO" IS NOT NULL)




CREATE TABLE dept_test2 AS
SELECT *
FROM dept
WHERE 1 = 1;

SELECT *
FROM dept_test2;

ALTER TABLE dept DROP CONSTRAINT pk_dept;
CREATE UNIQUE INDEX idx_u_dept_test2_01 ON dept_test2 (deptno);
CREATE INDEX idx_nu_dept_test2_02 ON dept_test2 (dname);
CREATE INDEX idx_nu_dept_test2_03 ON dept_test2 (deptno, dname);

DROP TABLE dept_test2;

DROP UNIQUE INDEX idx_u_dept_test2_01;
DROP INDEX idx_nu_dept_test2_02;
DROP INDEX idx_nu_dept_test2_03;


--실습 idx3
SELECT *
FROM emp
WHERE empno = :empno; --empno

SELECT *
FROM emp
WHERE ename = :ename; --ename 가장 뒤로

SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno
  AND emp.deptno = :deptno
  AND emp.empno LIKE :empno || '%'; --deptno(2), empno(1)
  
SELECT *
FROM emp
WHERE sal BETWEEN : st_sal AND :ed_sal
  AND deptno = :deptno; --deptno, sal(4)
  
SELECT *
FROM emp a, emp b
WHERE a.mgr = b.empno
  AND a.deptno = :deptno; --empno, mgr(3)

SELECT deptno, TO_CHAR(hiredate, 'yyyymm'), COUNT(*) cnt
FROM emp
GROUP BY deptno, TO_CHAR(hiredate, 'yyyymm'); --hiredate

SELECT *
FROM emp;

--------------------------------------------------------------------------------------

CREATE INDEX idx_nu_emp_01 ON emp (empno, deptno);
CREATE INDEX idx_nu_emp_02 ON emp (ename);
CREATE INDEX idx_nu_emp_03 ON emp (deptno, sal);
CREATE INDEX idx_nu_emp_04 ON emp (deptno, mgr);


DROP INDEX idx_nu_emp_04;

EXPLAIN PLAN FOR
SELECT deptno, TO_CHAR(hiredate, 'yyyymm'), COUNT(*) cnt
FROM emp
GROUP BY deptno, TO_CHAR(hiredate, 'yyyymm');

SELECT *
FROM TABLE(dbms_xplan.display);

SELECT empno, rowid
FROM emp
WHERE empno = :empno;

-------------------------------------------------------------------------------------------
[ 실습 idx3 해석 ] 
access pattern 분석
1. empno(=) ==> empno
2. ename(=) ==> ename
3. deptno(=), empno (LIKE) ==> 3,4,5 번 - deptno, empno, sal, hiredate
4. deptno(=), sal(BETWEEN) 
5. deptno(=), empno(=) 
6. deptno, hiredate 컬럼으로 구성된 인덱스가 있을 경우 table 접근이 필요 없음

emp테이블에 데이터가 5천만건
10, 20, 30 데이터는 각각 50건씩만 존재 ==> 인덱스

-------------------------------------------------------------------------------------------
GRANT CREATE SYNONYM TO (계정); --권한 부여

SYNONYM : 오라클 객체에 별칭을 생성
pc10.v_emp ==> v_emp

생성방법 CREATE SYNONYM 시노님이름 FOR 원본객체이름;
PUBLIC : 모든 사용자가 사용할 수 있는 시노님
         권한이 있어야 생성가능
PRIVATE [DEFAULT] : 해당 사용자만 사용할 수 있는 시노님

삭제방법
DROP SYNONYM 시노님이름;

--------------------------------------------------------------------------------------------

--과제 실습 idx4

DROP INDEX idx_nu_emp_04;
ALTER TABLE dept DROP CONSTRAINT pk_dept;


SELECT *
FROM emp
WHERE empno = :empno;


SELECT *
FROM dept
WHERE deptno = :deptno;


SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno
  AND emp.deptno = :deptno
  AND emp.empno LIKE :empno || '%'
  
  
SELECT *
FROM emp
WHERE sal BETWEEN : st_sal AND :ed_sal
  AND deptno = :deptno;

 
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno
  AND emp.deptno = :deptno
  AND dept.loc = :loc;

1. empno
2. deptno
3. deptno, empno
4. deptno, sal
5. deptno, loc

CREATE INDEX idx_nu_emp_01 ON emp (empno);
CREATE INDEX idx_nu_emp_02 ON emp (deptno);
CREATE INDEX idx_nu_emp_03 ON emp (deptno, sal);
CREATE INDEX idx_nu_emp_04 ON emp (deptno, loc);


EXPLAIN PLAN FOR
SELECT deptno, TO_CHAR(hiredate, 'yyyymm'), COUNT(*) cnt
FROM emp
GROUP BY deptno, TO_CHAR(hiredate, 'yyyymm');

SELECT COUNT(*)
FROM dept
WHERE deptno IN (10, 20, 30, 40);

SELECT *
FROM TABLE(dbms_xplan.display);

1. emp : empno(=)(e.1)
2. dept : deptno(=)(d.1)
3. emp : deptno(=), empno(LIKE)
   dept : empno(=)(d.1)
4. emp : deptno(=), sal(BETWEEN)
5. emp : deptno(=)
   dept : deptno(=), [loc(=)](d.1)
   
   emp : empno(=)(e.1)
   dept : loc(=)
   
emp 방향 : 1. empno
           2. deptno, empno
           2.2 deptno, empno, sal
           3. deptno, sal
           
dept 방향 : 1. deptno, loc
            2. loc