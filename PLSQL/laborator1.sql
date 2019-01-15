/*#1 exemple de declararii corecte
DECLARE 
    v_nume VARCHAR2 (35);
    v_prenume VARCHAR2 (35);
    v_nr NUMBER(5);
    v_nr2 NUMBER(5, 2) := 10;
    v_test BOOLEAN := TRUE;
    v1 NUMBER(5) := 10;
    v2 NUMBER(5) := 15;
    v3 BOOLEAN := v1 < v2;*/

--#2
<<principal>>
DECLARE    
    v_client_id NUMBER(4) := 1600;
    v_client_nume VARCHAR2(50) := 'N1';
    v_nou_client_id NUMBER(3) := 500;
BEGIN
    <<secundar>>
    DECLARE 
        v_client_id NUMBER(4) := 0;
        v_client_nume VARCHAR2(50) := 'N2';
        v_nou_client_id NUMBER(3) := 300;
        v_nou_client_nume VARCHAR(50) := 'N3';
    BEGIN
        v_client_id := v_nou_client_id;
        principal.v_client_nume :=
                  v_client_nume || ' ' || v_nou_client_nume;
        --pozitia 1
    END;
    v_client_id := (v_client_id * 12)/10;
    --pozitia 2
END;
/

--#3 invat PL/SQL 
VARIABLE g_mesaj VARCHAR2(50)
BEGIN
    :g_mesaj := 'Invat PL/SQL';
END;
/

PRINT g_mesaj

BEGIN
    DBMS_OUTPUT.PUT_LINE('Invat PL/SQL');
END;

--#4bloc anonim care sa se afle numele departamentului
--cu cei mai multi angajati
DECLARE 
    v_dep departments.department_name%TYPE;
BEGIN
    SELECT department_name
    INTO v_dep
    FROM employees e, departments d
    WHERE e.department_id = d.department_id
    GROUP BY department_name
    HAVING COUNT (*) = (SELECT MAX(COUNT(*))
                        FROM employees
                        GROUP BY department_id);
    DBMS_OUTPUT.PUT_line('Departmanetul ' || v_dep);
END;
/

--#5 problema anterioara utilizand variabile de legatura
VARIABLE rezultat VARCHAR2(35)
BEGIN
    SELECT department_name
    INTO :rezultat
    FROM employees e, departments d
    WHERE e.department_id=d.department_id
    GROUP BY department_name
    HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                       FROM employees
                       GROUP BY department_id);
    DBMS_OUTPUT.PUT_LINE('Departamentul '|| :rezultat);
END;
/
PRINT rezultat

--#6 si numarul de angajari din departament nu doar departamentul
VARIABLE rezultat VARCHAR2(35)
VARIABLE nr_angajati VARCHAR2(35)
BEGIN
    SELECT department_name, COUNT(*)
    INTO :rezultat, :nr_angajati
    FROM employees e, departments d
    WHERE e.department_id=d.department_id
    GROUP BY department_name
    HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                               FROM employees
                               GROUP BY department_id);
    DBMS_OUTPUT.PUT_LINE('Departamentul ' || :rezultat || ' are: ' 
                         || :nr_angajati || ' angajati');
END; 
/
PRINT rezultat
PRINT nr_angajati

--#7 citit un cod dat de la tastatura: determinat salariul anual
--si bonusul pe care il prmeste salaratiul ANUAL cu codul respectiv
SET VERIFY OFF
DECLARE
    v_cod           employees.employee_id%TYPE:=&p_cod;
    v_bonus         NUMBER(8);
    v_salariu_anual NUMBER(8);
BEGIN
    SELECT salary * 12 
    INTO v_salariu_anual
    FROM employees e
    WHERE e.employee_id = v_cod;
    IF v_salariu_anual >= 20001
        THEN v_bonus := 20000;
    ELSIF v_salariu_anual BETWEEN 10001 AND 20000
        THEN v_bonus := 1000;
    ELSE v_bonus := 500;
END IF;
DBMS_OUTPUT.PUT_LINE('Bonusul este ' || v_bonus);
END;
/
SET VERIFY ON
    
--#8 rezolvati #7 cu instructiunea case in loc de for
SET VERIFY OFF
DECLARE
    v_cod           employees.employee_id%TYPE:=&p_cod;
    v_bonus         NUMBER(8);
    v_salariu_anual NUMBER(8);
BEGIN
    SELECT salary * 12 
    INTO v_salariu_anual
    FROM employees e
    WHERE e.employee_id = v_cod;
    CASE v_salariu_anual
        WHEN v_salariu_anual >= 20001 
            THEN v_bonus := 20000;
        WHEN v_salariu_anual BETWEEN 10001 AND 20000 
            THEN v_bonus := 1000;
        ELSE v_bonus := 500;
    END CASE;
END IF;
DBMS_OUTPUT.PUT_LINE('Bonusul este ' || v_bonus);
END;
/
SET VERIFY ON

CREATE TABLE emp_mam
    AS (SELECT * FROM employees);

--#9 variabile de substitutie
DEFINE p_cod_sal= 200
DEFINE p_cod_dept = 80
DEFINE p_procent =20
DECLARE
    v_cod_sal emp_mam.employee_id%TYPE:= &p_cod_sal;
    v_cod_dept emp_mam.department_id%TYPE:= &p_cod_dept;
    v_procent NUMBER(8):=&p_procent;
BEGIN
UPDATE emp_mam
    SET department_id = v_cod_dept,
        salary=salary + (salary* v_procent/100)
    WHERE employee_id= v_cod_sal;
    IF SQL%ROWCOUNT =0 THEN
    DBMS_OUTPUT.PUT_LINE('Nu exista un angajat cu acest cod');
    ELSE DBMS_OUTPUT.PUT_LINE('Actualizare realizata');
    END IF;
END;
/
ROLLBACK;

--#10 creati tabelul zile_*** (id, data, nume_zi)
--introduceti in tabelul zile_*** informatiile coresp
--tuturor zilelor care au ramas din luna curenta
CREATE TABLE zile_zzz (
    id_zi  int,
    data_zi date,
    nume_zi varchar(25)
);

DECLARE
    contor  NUMBER(6) :=1;
    v_data  DATE;
    maxim   NUMBER(2) := LAST_DAY(SYSDATE)-SYSDATE;
BEGIN
    LOOP
        v_data := sysdate + contor;
        INSERT INTO zile_zzz
        VALUES (contor, v_data, to_char(v_data, 'Day'));
        contor := contor + 1;
        EXIT WHEN contor > maxim;
    END LOOP;
END;
/

SELECT * FROM zile_zzz

--#11 cerinta de mai sus dar cu instructiunea while
DECLARE
    contor  NUMBER(6) :=1;
    v_data  DATE;
    maxim   NUMBER(2) := LAST_DAY(SYSDATE)-SYSDATE;
BEGIN
    WHILE contor <= maxim LOOP
        v_data := sysdate + contor;
        INSERT INTO zile_zzz
        VALUES (contor, v_data, to_char(v_data, 'Day'));
        contor := contor + 1;
    END LOOP;
END;
/

--#12 cerinta de mai sus dar cu for
DECLARE
    contor  NUMBER(6) :=1;
    v_data  DATE;
    maxim   NUMBER(2) := LAST_DAY(SYSDATE)-SYSDATE;
BEGIN
    FOR contor IN 1..MAXIM LOOP
        v_data := sysdate + contor;
        INSERT INTO zile_zzz
        VALUES (contor, v_data, to_char(v_data, 'Day'));
    END LOOP;
END;
/

--#13 etichete pentru fete
DECLARE
    i POSITIVE:=1;
    max_loop CONSTANT POSITIVE:=10;
BEGIN
    LOOP
        i:=i+1;
        IF i>max_loop THEN
            DBMS_OUTPUT.PUT_LINE('in loop i=' || i);
            GOTO urmator;
        END IF;
    END LOOP;
    <<urmator>>
    i:=1;
    DBMS_OUTPUT.PUT_LINE('dupa loop i=' || i);
END;
/

DECLARE
    i POSITIVE:=1;
    max_loop CONSTANT POSITIVE:=10;
    BEGIN
    i:=1;
    LOOP
        i:=i+1;
        DBMS_OUTPUT.PUT_LINE('in loop i=' || i);
        EXIT WHEN i>max_loop;
    END LOOP;
    i:=1;
    DBMS_OUTPUT.PUT_LINE('dupa loop i=' || i);
END;
/

--#Exercitii
--#1
DECLARE
    numar number(3):=100;
    mesaj1 varchar2(255):='text 1';
    mesaj2 varchar2(255):='text 2';
BEGIN
    DECLARE
        numar number(3):=1;
        mesaj1 varchar2(255):='text 2';
        mesaj2 varchar2(255):='text 3';
    BEGIN
        numar:=numar+1;
        mesaj2:=mesaj2||' adaugat in sub-bloc';
    DBMS_OUTPUT.PUT_LINE(numar || ', ' || mesaj1 || ', ' || mesaj2);
    END;
    numar:=numar+1;
    mesaj1:=mesaj1||' adaugat un blocul principal';
    mesaj2:=mesaj2||' adaugat in blocul principal';
    DBMS_OUTPUT.PUT_LINE(numar || ', ' || mesaj1 || ', ' || mesaj2);
END;
/

--#2 pentru fiecare zi a lunii ocmobrie obtineti nr de imprumuturi efectuate
SELECT DISTINCT book_date
FROM rental r
GROUP BY book_date