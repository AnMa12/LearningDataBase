--laboratorul 6
--triggere

/*1. Definiţi un declanşator care să permită lucrul asupra tabelului emp_mam (INSERT, UPDATE,
DELETE) doar în intervalul de ore 8:00 - 20:00, de luni până sâmbătă (declanşator la nivel
de instrucţiune).*/

CREATE OR REPLACE TRIGGER t1_mam
    BEFORE INSERT OR UPDATE OR DELETE ON emp_mam
BEGIN
    IF (TO_CHAR(SYSDATE,'D')=1) OR (TO_CHAR(SYSDATE,'HH24') NOT BETWEEN 8 AND 20)
        THEN RAISE_APPLICATION_ERROR(-2001, 'NU SE POT FACE MODIFICARI ASUPRA BAZEI DE DATE');
    END IF;
END;
/

DROP TRIGGER t1_mam;

/*2. Definiţi un declanşator prin care să nu se permită micşorarea salariilor angajaţilor din tabelul
emp_mam (declanşator la nivel de linie).*/

--varianta 1
CREATE OR REPLACE TRIGGER t2_mam
    BEFORE UPDATE OF salary ON emp_mam
    FOR EACH ROW
BEGIN
    IF(:NEW.salary < :OLD.salary)
        THEN RAISE_APPLICATION_ERROR(-20002,'salariul nu poate fi micsorat');
    END IF;
END;
/

--varianta 2
CREATE OR REPLACE TRIGGER t2_mam
    BEFORE UPDATE OF salary ON emp_mam
    FOR EACH ROW
    WHEN (OLD.salary > NEW.salary)
BEGIN
    RAISE_APPLICATION_ERROR(-20002,'salariul nu poate fi micsorat');
END;
/

DROP TRIGGER t2_mam;

UPDATE emp_mam
SET salary = salary - 100;

/*3. Creaţi un declanşator care să nu permită mărirea limitei inferioare a grilei de salarizare 1,
respectiv micşorarea limitei superioare a grilei de salarizare 7 decât dacă toate salariile se
găsesc în intervalul dat de aceste două valori modificate. Se va utiliza tabelul job_grades_mam.*/

CREATE TABLE job_grades_mam
    AS (SELECT * FROM job_grades);
    
CREATE OR REPLACE TRIGGER trig3_mam
    BEFORE UPDATE OF lowest_sal, highest_sal ON job_grades_mam
    FOR EACH ROW
BEGIN 
    --daca toate salariile se gasesc in intervalul dat de aceste doua valori modificate
    IF (SELECT COUNT(salary) FROM employees
    WHERE salary >= :NEW.lowest_sal AND salary <= :NEW.highest_sal) ~= 0
        THEN RAISE_APPLICATION_ERROR(-2003, 'nu s-a putut acutaliza baza de date, limite proaste';
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trig3_mam
    BEFORE UPDATE OF lowest_sal, highest_sal ON job_grades_mam
    FOR EACH ROW
DECLARE 
    v_min_sal emp_mam.salary%TYPE;
    v_max_sal emp_mam.salary%TYPE;
    exceptie EXCEPTION;
BEGIN
    SELECT MIN(salary), MAX(salary)
    INTO v_min_sal, v_max_sal
    FROM emp_mam;
    
    IF (:OLD.grade_level = 1) AND (:NEW.lowest_sal > v_min_sal)
        THEN RAISE exceptie;
    END IF;
    
    IF (:OLD.grade_level = 7) AND (:NEW.highest_sal < v_max_sal)
        THEN RAISE exceptie;
    END IF;
    
EXCEPTION
    WHEN exceptie THEN
        RAISE_APPLICATION_ERROR (-20003, 'Exista salarii care se
            gasesc in afara intervalului');
END;
/

UPDATE job_grades_mam
SET lowest_sal = 3000
WHERE grade_level = 1;

DROP TRIGGER trig3_mam;

/*4. a. Creaţi tabelul info_dept_mam cu următoarele coloane:
- id (codul departamentului) – cheie primară;
- nume_dept (numele departamentului);
- plati (suma alocată pentru plata salariilor angajaţilor care lucrează în departamentul
respectiv).
b. Introduceţi date în tabelul creat anterior corespunzătoare informaţiilor existente în schemă.
c. Definiţi un declanşator care va actualiza automat câmpul plati atunci când se introduce un
nou salariat, respectiv se şterge un salariat sau se modifică salariul unui angajat.*/

CREATE TABLE info_dept_mam ( id int NOT NULL,
                             nume_dept  VARCHAR(25),
                             plati int,
                             PRIMARY KEY (ID)
                           );

CREATE OR REPLACE TRIGGER trig_info_dept 
    AFTER CREATE OR UPDATE OR DELETE ON info_dept_mam
DECLARE 
    v_suma_salarii employees.salary%TYPE;
BEGIN
    SELECT SUM(salary) 
    INTO v_suma_salarii
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE d.department_name = :OLD.nume_dept;
    
    UPDATE TABLE info_dept_mam
    SET plati = v_suma_salarii;
END;
/

--pentru ca am trecut prin laboratoare si suntem smekeri
--facem cu procedura desigur #likeAboss

CREATE OR REPLACE PROCEDURE p1_mam( v_plata   IN info_dept_mam.plati%TYPE,  
                                    v_id_dept IN info_dept_mam.id%TYPE) IS
BEGIN
    UPDATE info_dept_mam
    SET plati = NVL( plati, 0) + v_plata
    WHERE id = v_id_dept;
END;
/

CREATE OR REPLACE TRIGGER t4_mam
    AFTER INSERT OR UPDATE OR DELETE OF salary ON emp_mam
    FOR EACH ROW
BEGIN
    IF DELETING
        THEN p1_mam( (-1) * :OLD.salary ,:OLD.department_id);
    ELSIF UPDATING
        THEN p1_mam( :NEW.salary - :OLD.salary, :OLD.department_id);
    ELSIF INSERTING
        THEN p1_mam( :NEW.salary, :NEW.department_id);
    END IF;
END;
/
                                 
SELECT * FROM info_dept_mam WHERE id=90;

INSERT INTO emp_mam (employee_id, last_name, email, hire_date,
job_id, salary, department_id)
VALUES (300, 'N1', 'n1@g.com',sysdate, 'SA_REP', 2000, 90);

SELECT * FROM info_dept_mam WHERE id=90;

UPDATE emp_mam
SET salary = salary + 1000
WHERE employee_id=300;

SELECT * FROM info_dept_mam WHERE id=90;

DELETE FROM emp_mam
WHERE employee_id=300;

SELECT * FROM info_dept_mam WHERE id=90;

DROP TRIGGER trig4_mam;        

/*5. a. Creaţi tabelul info_emp_mam cu următoarele coloane:
- id (codul angajatului) – cheie primară;
- nume (numele angajatului);
- prenume (prenumele angajatului);
- salariu (salariul angajatului);
- id_dept (codul departamentului) – cheie externă care referă tabelul info_dept_mam.*/
CREATE TABLE info_emp_mam ( id int,
                           nume varchar(25),
                           prenume varchar(25),
                           salariu int,
                           id_dept int,
                           PRIMARY KEY (id),
                           FOREIGN KEY (id_dept) REFERENCES info_dept_mam(id));

/*b. Introduceţi date în tabelul creat anterior corespunzătoare informaţiilor existente în schemă.*/

/*c. Creaţi vizualizarea v_info_mam care va conţine informaţii complete despre angajaţi şi
departamentele acestora. Folosiţi cele două tabele create anterior, info_emp_mam, respectiv
info_dept_mam.*/

CREATE OR REPLACE VIEW v_info_mam AS
    SELECT e.id, e.nume, e.prenume, e.salariu, e.id_dept, d.nume_dept, d.plati
    FROM info_emp_mam e, info_dept_mam d
    WHERE e.id_dept = d.id;

/*d. Se pot realiza actualizări asupra acestei vizualizări? Care este tabelul protejat prin cheie?
Consultaţi vizualizarea user_updatable_columns.*/

SELECT *
FROM user_updatable_columns
WHERE table_name = UPPER('v_info_mam');

/*e. Definiţi un declanşator prin care actualizările ce au loc asupra vizualizării se propagă
automat în tabelele de bază (declanşator INSTEAD OF). Se consideră că au loc
următoarele actualizări asupra vizualizării:
- se adaugă un angajat într-un departament deja existent;
- se elimină un angajat;
- se modifică valoarea salariului unui angajat;
- se modifică departamentul unui angajat (codul departamentului).*/

CREATE OR REPLACE TRIGGER trig5_mam
    INSTEAD OF INSERT OR DELETE OR UPDATE ON v_info_mam
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
    -- inserarea in vizualizare determina inserarea
    -- in info_emp_mam si reactualizarea in info_dept_mam
    -- se presupune ca departamentul exista
        INSERT INTO info_emp_mam
        VALUES (:NEW.id, :NEW.nume, :NEW.prenume, :NEW.salariu,
        :NEW.id_dept);
        
        UPDATE info_dept_mam
        SET plati = plati + :NEW.salariu
        WHERE id = :NEW.id_dept;
    ELSIF DELETING THEN
    -- stergerea unui salariat din vizualizare determina
    -- stergerea din info_emp_mam si reactualizarea in
    -- info_dept_mam
        DELETE FROM info_emp_mam
        WHERE id = :OLD.id;
        
        UPDATE info_dept_mam
        SET plati = plati - :OLD.salariu
        WHERE id = :OLD.id_dept;
        ELSIF UPDATING ('salariu') THEN
        /* modificarea unui salariu din vizualizare determina
        modificarea salariului in info_emp_mam si reactualizarea
        in info_dept_mam */
        UPDATE info_emp_mam
        SET salariu = :NEW.salariu
        WHERE id = :OLD.id;
        
        UPDATE info_dept_mam
        SET plati = plati - :OLD.salariu + :NEW.salariu
        WHERE id = :OLD.id_dept;
    ELSIF UPDATING ('id_dept') THEN
    /* modificarea unui cod de departament din vizualizare
    determina modificarea codului in info_emp_mam
    si reactualizarea in info_dept_mam */
        UPDATE info_emp_mam
        SET id_dept = :NEW.id_dept
        WHERE id = :OLD.id;
        
        UPDATE info_dept_mam
        SET plati = plati - :OLD.salariu
        WHERE id = :OLD.id_dept;
        
        UPDATE info_dept_mam
        SET plati = plati + :NEW.salariu
        WHERE id = :NEW.id_dept;
    END IF;
END;
/

SELECT *
FROM user_updatable_columns
WHERE table_name = UPPER('v_info_mam');

-- adaugarea unui nou angajat
SELECT * FROM info_dept_mam WHERE id=10;
INSERT INTO v_info_mam
VALUES (400, 'N1', 'P1', 3000,10, 'Nume dept', 0);
SELECT * FROM info_emp_mam WHERE id=400;
SELECT * FROM info_dept_mam WHERE id=10;

/*6. Definiţi un declanşator care să nu se permită ştergerea informaţiilor din tabelul emp_*** de
către utilizatorul grupa***.*/