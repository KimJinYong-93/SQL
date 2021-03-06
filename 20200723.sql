계층쿼리
    테이블(데이터셋)의 행과 행사이의 연관 관계를 추적하는 쿼리
    ex - emp테이블 해당 사원의 mgr 컬럼을 통해 상급자 추적 가능
        1. 상급자 직원을 다른 테이블로 관리하지 않음
            1-1. 상급자 구조가 계층이 변경이 되도 테이블의 구조는 변경 할 필요가 없다.
            
        2. join - 테이블간 연결
                  FROM emp, dept
                  WHERE emp.deptno = dept.deptno
           계층쿼리는 행과 행사이의 연결 (자기 참조)
                  PRIOR - 현재 읽고 있는 행을 지칭
                  X - 앞으로 읽을 행
                  
----------------------------------------------------------------------------------------------------------

[ 실습 h_4 ]

SELECT LPAD(' ', (LEVEL - 1) * 4) || s_id s_id, value
FROM h_sum
START WITH s_id = '0'
CONNECT BY PRIOR s_id = ps_id;

----------------------------------------------------------------------------------------------------------

[ 실습 h_5 ]

SELECT LPAD(' ', (LEVEL-1)*4) || org_cd org_cd, no_emp
FROM no_emp
START WITH org_cd = 'XX회사'
CONNECT BY PRIOR org_cd = parent_org_cd;

----------------------------------------------------------------------------------------------------------

[ 가지치기 pruning branch ]
SELECT 쿼리의 실행순서 - FROM -> WHERE -> SELECT -> (GROUP BY ->) ORDER BY
계층쿼리의 SELECT 쿼리 실행순서 - FROM -> START WITH, CONNECT BY -> WHERE 

계층쿼리에서 조회할 행의 조건을 기술할 수 있는 부분이 2곳 존재
1. CONNECT BY - 다음 행으로 연결할지, 말지를 결정
2. WHERE - START WITH, CONNECT BY 에 의해 조회된 행을 대상으로 적용
;

SELECT LPAD(' ', (LEVEL-1)*4) || deptnm deptnm
FROM dept_h
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = p_deptcd AND deptnm != '정보기획부';

SELECT LPAD(' ', (LEVEL-1)*4) || deptnm deptnm
FROM dept_h
WHERE deptnm != '정보기획부'
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = p_deptcd;

SELECT *
FROM dept_h;

----------------------------------------------------------------------------------------------------------

[ 계층쿼리에서 사용할 수 있는 특수함수 ]

CONNECT_BY_ROOT(col) - 최상위 행의 col 컬럼의 값
SYS_CONNECT_BY_PATH(col, 구분자) - 계층의 순회경로를 표현(각 계층을 지나면서 어떤 컬럼을 지나 왔는지)
CONNECT_BY_ISLEAF - 해당 행이 LEAF 노드(1)인지 아닌지(0)를 반환
LTRIM(컬럼, '지울문자열') - 왼쪽에 있는 문자열을 지운다

SELECT deptcd, p_deptcd, LPAD(' ', (LEVEL-1)*4) || deptnm deptnm,
       CONNECT_BY_ROOT(deptnm),
       LTRIM(SYS_CONNECT_BY_PATH(deptnm, '-'), '-'),
       CONNECT_BY_ISLEAF
FROM dept_h
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = p_deptcd;

----------------------------------------------------------------------------------------------------------

[ 실습 h6 ]

SELECT *
FROM board_test;

SELECT seq, LPAD(' ', (LEVEL-1)*4) || title title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq;

----------------------------------------------------------------------------------------------------------

[ 실습 h7 ]

SELECT seq, LPAD(' ', (LEVEL-1)*4) || title title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER BY seq desc;

----------------------------------------------------------------------------------------------------------

[ 실습 h8 ]

SELECT seq, LPAD(' ', (LEVEL-1)*4) || title title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY seq desc; --SIBLINGS 계층쿼리의 구조를 유지해준다.

----------------------------------------------------------------------------------------------------------

[ 실습 h9 ]

ALTER TABLE board_test ADD (gn NUMBER);

4번글 하위에있는 모든 글들
UPDATE board_test SET gn = 4
WHERE seq IN (4, 5, 6, 7, 8, 10, 11);

UPDATE board_test SET gn = 1
WHERE seq IN (1, 9);

UPDATE board_test SET gn = 2
WHERE seq IN (2, 3);

SELECT *
FROM board_test;

SELECT *
FROM
(SELECT seq, gn, CONNECT_BY_ROOT(seq) s_gn, parent_seq, LPAD(' ', (LEVEL-1)*4) || title title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq)
ORDER BY s_gn DESC, seq;

SELECT seq, seq-parent_seq, LPAD(' ', (LEVEL-1)*4) || title title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY seq-parent_seq, seq DESC;

----------------------------------------------------------------------------------------------------------

[ 분석 함수 ]

[ 도전해보기 실습 ana0 ]

SELECT emp.*, 1 sal_rank, 
       
        
FROM emp
ORDER BY deptno;

SELECT ename, sal, deptno, 1 sal_rank
FROM emp
ORDER BY deptno;

UPDATE emp_test SET sal = sal + 200
WHERE sal > (SELECT sal
             FROM emp_test e
             WHERE emp_test.deptno = e.deptno);

SELECT emp.*, 1 sal_rank
FROM emp
ORDER BY deptno, sal DESC;

순위를 매길 대상 ==> 부서별 sal

SELECT *
FROM
(SELECT LEVEL lv
 FROM dual
 CONNECT BY LEVEL <= 14) a,

(SELECT deptno, COUNT(*) cnt
 FROM emp
 GROUP BY deptno) b
 WHERE a.lv <= b.cnt
 ORDER BY b.deptno, a.lv;
 
                             ----------------------------------------------------
                             
SELECT a.ename, a.sal, a.deptno, b.lv
FROM 
(SELECT ROWNUM rn, a.*
 FROM 
    (SELECT ename, sal, deptno
     FROM emp
     ORDER BY deptno, sal DESC) a ) a,
 
(SELECT ROWNUM rn, a.lv
FROM 
(SELECT b.deptno, a.lv
    FROM 
    (SELECT LEVEL lv
     FROM dual
     CONNECT BY LEVEL <= (SELECT COUNT(*) FROM emp) a,
    (SELECT deptno, COUNT(*) cnt
     FROM emp
     GROUP BY deptno) b
    WHERE a.lv <= b.cnt
    ORDER BY b.deptno, a.lv ) a )b
WHERE a.rn = b.rn;
 
----------------------------------------------------------------------------------------------------------

[ 위와 동일한 동작을 하는 윈도우 함수 ]

윈도우 함수 미사용 - emp 테이블 3번 조회
윈도우 함수 사용 - emp 테이블 1번 조회

SELECT ename, sal, deptno,
       RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_rank
FROM emp;       

윈도우 함수를 사용하면 행간 연산이 가능해짐 ==> 일반적으로 풀리지 않는 쿼리를 간단하게 만들 수 있다.
**모든 DBMS 가 동일한 윈도우 함수를 제공하지는 않음

문법 : 윈도우 함수 OVER ( [PARTITION BY 컬럼] [ORDER BY 컬럼] [WINDOWING] )
PARTITION BY - 행들을 묶을 그룹 (GROUP BY 와 유사)
ORDER BY - 묶여진 행들간 순서 (RANK - 순위의 경우 순서를 설정하는 기준이 된다)
WINDOWING - 파티션 안에서 특정 행들에 대해서만 연산을 하고 싶을 때 범위를 지정

순위 관련 함수
1. RANK() - 동일 값일 때는 동일 순위 부여, 후순위는 중복자만큼 건너 띄고 부여
            1등이 2명이면 후순위는 3등
2. DENSE_RANK() - 동일 값일 때는 동일 순위 부여, 후순위는 이어서 부여
                  1등이 2명이어도 후순위는 2등
3. ROW_NUMBER() - 중복되는 값이 없이 순위 부여 (ROWNUM 과 유사)

SELECT ename, sal, deptno,
       RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_rank,
       DENSE_RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_dense_rank,
       ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY sal DESC) sal_row_number
FROM emp;

----------------------------------------------------------------------------------------------------------

[ 실습 no_ana2 ]

SELECT a.*, b.cnt
FROM
(SELECT empno, ename, deptno
FROM emp
ORDER BY deptno) a,
(SELECT deptno, COUNT(*) cnt
FROM emp
GROUP BY deptno) b
WHERE a.deptno = b.deptno;

----------------------------------------------------------------------------------------------------------

[ 집계 윈도우 함수 ] - SUM, MAX, MIN, AVG, COUNT
SELECT empno, ename, deptno, COUNT(*) OVER ( PARTITION BY deptno ) cnt
FROM emp;

----------------------------------------------------------------------------------------------------------

[ 실습 ana2 ]

SELECT empno, ename, sal, deptno, ROUND(AVG(sal) OVER ( PARTITION BY deptno ), 2) avg_sal
FROM emp;

----------------------------------------------------------------------------------------------------------

[ 실습 ana3~4 ]

SELECT empno, ename, sal, deptno, MAX(sal) OVER ( PARTITION BY deptno ) max_sal,
                                  MIN(sal) OVER ( PARTITION BY deptno ) min_sal
FROM emp;


