SELECT 
       MAX(DECODE(d, 1, dt, null)) sun, MAX(DECODE(d, 2, dt, null)) mon,
       MAX(DECODE(d, 3, dt, null)) tue, MAX(DECODE(d, 4, dt, null)) wed,
       MAX(DECODE(d, 5, dt, null)) thu, MAX(DECODE(d, 6, dt, null)) fri,
       MAX(DECODE(d, 7, dt, null)) sat
FROM
(SELECT TO_DATE(:yyyymm, 'YYYYMM') + (level - 1) dt,
        TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (level - 1), 'D') d,
        TO_DATE(:yyyymm, 'YYYYMM') + (level - 1) 
        - ((TO_DATE(:yyyymm, 'YYYYMM') + (level - 1) - TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (level - 1), 'd') - 1)) p
        
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 'DD'))
GROUP BY DECODE(d, 1, p + 1, p)
ORDER BY p;

WITH dt AS (
    SELECT TO_DATE('2019/12/01', 'YYYY/MM/DD') dt FROM dual UNION ALL
    SELECT TO_DATE('2019/12/02', 'YYYY/MM/DD') dt FROM dual UNION ALL
    SELECT TO_DATE('2019/12/03', 'YYYY/MM/DD') dt FROM dual UNION ALL
    SELECT TO_DATE('2019/12/04', 'YYYY/MM/DD') dt FROM dual UNION ALL
    SELECT TO_DATE('2019/12/05', 'YYYY/MM/DD') dt FROM dual UNION ALL
    SELECT TO_DATE('2019/12/06', 'YYYY/MM/DD') dt FROM dual UNION ALL
    SELECT TO_DATE('2019/12/07', 'YYYY/MM/DD') dt FROM dual UNION ALL
    SELECT TO_DATE('2019/12/08', 'YYYY/MM/DD') dt FROM dual UNION ALL
    SELECT TO_DATE('2019/12/09', 'YYYY/MM/DD') dt FROM dual UNION ALL
    SELECT TO_DATE('2019/12/10', 'YYYY/MM/DD') dt FROM dual)
SELECT dt, dt - (TO_CHAR(dt, 'd') - 1)
FROM dt;

--------------------------------------------------------------------------------------------------------

mybatis
SELECT - 결과가 1건이나, 복수거나
    1건 - sqlSession.selectOne("네임스페이스.sqlid", [인자]) ==> overloading
          리턴타입 : resultType
    복수건 - sqlSession.selectList("네임스페이스.sqlid", [인자]) ==> overloading
            리턴타입 List<resultType>;

--------------------------------------------------------------------------------------------------------

오라클 계층쿼리 - 하나의 테이블(혹은 인라인뷰)에서 특정 행을 기준으로 다른 행을 찾아가는 문법
조인 ==> 테이블 - 테이블
계층쿼리 ==> 행 - 행

1. 시작점(행)을 설정
2. 시작점(행)과 다른 행을 연결시킬 조건을 기술

1. 시작점 - mgr 정보가 없는 KING
2. 연결 조건 - KING을 mgr 컬럼으로 하는 사원

SELECT LPAD('기준문자열', 15, '*')
FROM dual;

LEVEL - 1 0칸
LEVEL - 2 4칸
LEVEL - 3 8칸

SELECT LPAD(' ', (LEVEL-1)*4) || ename, LEVEL
FROM emp
START WITH ename = 'BLAKE'
CONNECT BY PRIOR empno = mgr;

최하단 노드에서 상위 노드로 연결하는 상향식 연결방법
시작점 - SMITH

SELECT LPAD(' ', (LEVEL - 1) * 4) || ename, emp.*
FROM emp
START WITH ename = 'SMITH'
CONNECT BY empno = PRIOR mgr AND PRIOR hiredate < hiredate; 
--PRIOR 키워드는 CONNECT BY 키워드와 떨어져서 사용해도 무관
--PRIOR 키워드는 현재 읽고 있는 행을 지칭하는 키워드
                              
--------------------------------------------------------------------------------------------------------

[ 실습 h_1 ]

SELECT *
FROM dept_h;

XX회사 부서부터 시작하는 하향식 계층쿼리 작성, 부서이름과 LEVEL 컬럼을 이용하여 들여쓰기 표현

SELECT LPAD(' ', (LEVEL - 1) * 4) || deptnm
FROM dept_h
START WITH deptnm = 'XX회사'
CONNECT BY PRIOR deptcd = p_deptcd;

--------------------------------------------------------------------------------------------------------

[ 실습 h_3 ]

SELECT *
FROM dept_h;

SELECT deptcd, LPAD(' ', (LEVEL - 1) * 4) || deptnm deptnm, p_deptcd
FROM dept_h
START WITH deptnm = '디자인팀'
CONNECT BY PRIOR p_deptcd = deptcd;

--------------------------------------------------------------------------------------------------------




