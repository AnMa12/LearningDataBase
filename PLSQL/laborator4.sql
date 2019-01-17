--subprograme
--#1 subprogram local
DECLARE
    v_nume employees.first_name%TYPE := Initcap('&p_nume');
    FUNCTION f1 RETURN NUMBER IS 
        salariu employees.salary%TYPE;
    BEGIN 
        SELECT salary
        INTO salariu
        FROM employees e
        WHERE e.last_name = v_nume;
        RETURN salariu;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            DBMS_OUTPUT.PUT_LINE('Nu s-a gasit userul cu numele dat');
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('Sunt mai multi fraieri cu numele dat');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Alta eroare!');
    END f1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Salariul este ' || f1);
END;
/

--#2 functia stocata
CREATE OR REPLACE FUNCTION f2_mam
    (v_nume employees.last_name%TYPE DEFAULT 'Bell')
RETURN NUMBER IS
    salariu employees.salary%TYPE;
BEGIN
    SELECT salary
    INTO salariu
    FROM employees e
    WHERE e.last_name = v_nume;
    RETURN salariu;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-2000,'nu-i');
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-2001,'e prea multi');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-2002,'odars');
END f2_mam;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(f2_mam('Bell'));
END;
/
        
--#3 procedura pentru cerinta de la 1
DECLARE
    v_nume employees.last_name%TYPE := Initcap('&p_nume');
    PROCEDURE p1 IS
        salariu employees.salary%TYPE;
    BEGIN
        SELECT salary
        INTO salariu
        FROM employees e
        WHERE e.last_name = v_nume;
        DBMS_OUTPUT.PUT_LINE('sal e' || salariu);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu numele dat');
        WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Exista mai multi angajati '||
        'cu numele dat');
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Alta eroare!');
    END p1;
BEGIN
    p1;
END;
/

-- sau cu OUT
DECLARE
    v_nume employees.last_name%TYPE := Initcap('&p_nume');
    v_salariu employees.salary%type;
    PROCEDURE p1(salariu OUT employees.salary%TYPE) IS
    BEGIN
        SELECT salary
        INTO salariu
        FROM employees e
        WHERE e.last_name = v_nume;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu numele dat');
        WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Exista mai multi angajati '||
        'cu numele dat');
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Alta eroare!');
    END p1;
BEGIN
    p1(v_salariu);
    DBMS_OUTPUT.PUT_LINE('Salariul este '|| v_salariu);
END;
/

--#4 procedura stocata pentru 1
    --DE FACUT
    
--#5 
CREATE OR REPLACE PROCEDURE p5_mam (cod_angajat IN OUT employees.employee_id%TYPE) IS
BEGIN 
    SELECT manager_id
    INTO cod_angajat
    FROM employees e
    WHERE e.employee_id = cod_angajat;
EXCEPTION
    WHEN NO_DATA_FOUND
       THEN RAISE_APPLICATION_ERROR(-2000,'NU-I');
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR(-2002,'PA');
END p5;
/

/*#6Declaraţi o procedură locală care are parametrii:
- rezultat (parametru de tip OUT) de tip last_name din employees;
- comision (parametru de tip IN) de tip commission_pct din employees, iniţializat cu NULL;
- cod (parametru de tip IN) de tip employee_id din employees, iniţializat cu NULL.
Dacă comisionul nu este NULL atunci în rezultat se va memora numele salariatului care are
comisionul respectiv. În caz contrar, în rezultat se va memora numele salariatului al cărui cod are
valoarea dată în apelarea procedurii.*/

DECLARE
    nume employees.last_name%TYPE;
    PROCEDURE p6(rezultat OUT employees.last_name%TYPE,
                 comision IN employees.commission_pct%TYPE DEFAULT NULL,
                 cod IN employees.employee_id%TYPE DEFAULT NULL) IS
    BEGIN
        IF comision IS NOT NULL
            THEN
                SELECT last_name
                INTO rezultat
                FROM employees e
                WHERE e.commission_pct = comision;
                DBMS_OUTPUT.PUT_LINE('numele salariatului care are comisionul'
||comision||' este '||rezultat);
        ELSIF comision IS NULL AND cod IS NOT NULL
            THEN 
                SELECT last_name
                INTO rezultat
                FROM employees e
                WHERE e.employee_id = cod;
                DBMS_OUTPUT.PUT_LINE('numele salariatului avand codul
'||cod||' este '||rezultat);
        ELSE
            DBMS_OUTPUT.PUT_LINE('ambele IN null');        
        END IF;
    END p6;
BEGIN
    p6(nume,0.4);
    p6(nume,cod=>200);
END;
/

/*7. Definiţi două funcţii locale cu acelaşi nume (overload) care să calculeze media salariilor astfel:
- prima funcţie va avea ca argument codul departamentului, adică funcţia calculează media
salariilor din departamentul specificat;
- a doua funcţie va avea două argumente, unul reprezentând codul departamentului, iar celălalt
reprezentând job-ul, adică funcţia va calcula media salariilor dintr-un anumit departament şi
care aparţin unui job specificat.*/
DECLARE
    medie1 NUMBER(10,2);
    medie2 NUMBER(10,2);
    FUNCTION f1(dep employees.department_id%TYPE) 
        RETURN NUMBER IS
        medie_salariu NUMBER(10,2);
    BEGIN
        SELECT SUM(salary)
        INTO medie_salariu
        FROM employees e
        WHERE e.department_id = dep;
        RETURN medie_salariu;
    END f1;
    FUNCTION f1(dep employees.department_id%TYPE, 
                jb employees.job_id%TYPE) 
        RETURN NUMBER IS
        medie_salariu NUMBER(10,2);
    BEGIN
        SELECT SUM(salary)
        INTO medie_salariu
        FROM employees e
        WHERE e.department_id = dep AND  e.job_id = jb;
        RETURN medie_salariu;
    END f1;
BEGIN
    medie1:=f1(80);
    DBMS_OUTPUT.PUT_LINE('Media salariilor din departamentul 80'
        || ' este ' || medie1);
    medie2 := f1(80,'SA_MAN');
    DBMS_OUTPUT.PUT_LINE('Media salariilor managerilor din'
        || ' departamentul 80 este ' || medie2);
END;
/

--%8 calculeaza factorial recursiv
CREATE OR REPLACE FUNCTION factorial_mam(n NUMBER) RETURN NUMBER IS
BEGIN
    IF n = 0
        THEN RETURN 1;
    ELSE 
        RETURN n*factorial_mam(n - 1);
    END IF;
END factorial_mam;
/

/*9. Afişaţi numele şi salariul angajaţilor al căror salariu este mai mare decât media tuturor
salariilor. Media salariilor va fi obţinută prin apelarea unei funcţii stocate.*/
CREATE OR REPLACE FUNCTION media_salarii_mam RETURN NUMBER IS
    medie NUMBER;
BEGIN
    SELECT AVG(salary)
    INTO medie
    FROM employees;
    RETURN medie;
END media_salarii_mam;
/

SELECT last_name, salary
FROM employees
WHERE salary > media_salarii_mam;