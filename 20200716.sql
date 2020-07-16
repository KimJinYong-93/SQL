개발자가 SQL 을 DBMS 에 요청을 하더라도
1. 오라클 서버가 항상 최적의 실행계획을 선택할 수는 없음
   (응답성이 중요하기 때문 : OLTP - Online Transaction Processing 
                          정해진 시간에 데이터를 가공하거나 시스템을 처리
    전체 처리 시간이 중요  : OLAP - Online Analytical Processing
                          은행이자 ==> 실행계획을 세우는데 30분 이상이 소요 되기도 함)
2. 항상 실행계획을 세우지 않음
   만약 동일한 SQL 이 이미 실행된 적이 있으면 해당 SQL 의 실행계획을 새롭게 세우지 않고 
   Shared pool(메모리)에 존재하는 실행계획을 재사용
   동일한 SQL - 문자가 완벽하게 동일한 SQL
               SQL 의 실행 결과가 같다고 해서 동일한 SQL 이 아님
               대소문자를 가리고, 공백도 문자로 취급
  EX - SELECT * FROM emp;
       select * FROM emp; 두개의 SQL 이 서로 다른 SQL 로 인식
/* SELECT *
   FROM v$sql
   WHERE sql_text LIKE '%plan_test%';   system 계정에서 볼 수 있다.*/
       
SELECT /* plan_test(의미 없는 주석) */ *
FROM emp
WHERE empno = 7698;
   
select /* plan_test(의미 없는 주석) */ *
FROM emp
WHERE empno = 7698; --실행계획이 하나 늘어난다.

select /* plan_test(의미 없는 주석) */ *
FROM emp
WHERE empno = :empno;

-----------------------------------------------------------------------------------------

NESTED LOOPS ==> 첫번째 자식이 돌고, 두번째 자식을 처리
 ** 후행 테이블은 선행 테이블보다 실행이 많이 되므로 후행 테이블에 인덱스가 없으면 비효율이 심하다.
 
I/O의 기준은 싱글블럭 ==> 대량의 데이터는 인덱스가 없는게 낫다.

Sort Merge Join 은 정렬이 먼저 끝나야 응답을 할 수 있다. ==> 속도가 느리다.

-----------------------------------------------------------------------------------------

DCL - Data Control Language ==> 시스템 권한 또는 객체 권한을 부여 / 회수

권한부여
GRANT 권한명 | 롤명 TO 사용자;

권한회수
REVOKE 권한명 | 롤명 FROM 사용자;




SELECT *
FROM dictionary;

SELECT *
FROM user_tables;

SELECT *
FROM all_tables; 

SELECT *
FROM dba_tables; --system 계정에서 조회 가능

DATA DICTIONARY
오라클 서버가 사용자 정보를 관리하기 위해 저장한 데이터를 볼 수 있는 view

CATEGORY(접두어)
USER_ ==> 해당 사용자가 소유한 객체 관련 조회
ALL_ ==> 해당 사용자가 소유한 객체 + 권한을 부여받은 객체 조회
DBA_ ==> 데이터베이스에 설치된 모든 객체(DBA 권한이 있는 사용자만 가능-SYSTEM)
v$ ==> 성능, 모니터와 관련된 특수 view
