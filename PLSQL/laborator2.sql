--#1 care este rezultatul urm bloc PL/SQL
--nu inteleg ce se intampla aici :(
DECLARE
    x NUMBER(1) := 5;
    y x%TYPE := NULL;
BEGIN
    IF x <> y THEN
        DBMS_OUTPUT.PUT_LINE ('valoare <> null este = true');
    ELSE
        DBMS_OUTPUT.PUT_LINE ('valoare <> null este != true');
    END IF;
    x := NULL;
    IF x = y THEN
        DBMS_OUTPUT.PUT_LINE ('null = null este = true');
    ELSE
        DBMS_OUTPUT.PUT_LINE ('null = null este != true');
    END IF;
END;
/

--#2 tipul de date record
--a) date date de noi
DECLARE
    TYPE emp_record IS RECORD
        (cod      employees.employee_id%TYPE,
         salariu  employees.salary%TYPE,
         job      employees.job_id%TYPE);
    v_ang emp_record;
BEGIN 
    v_ang.cod     := 700;
    v_ang.salariu := 9000;
    v_ang.job     := 'SA_MAN';
    DBMS_OUTPUT.PUT_LINE ('Angajatul cu codul ' || v_ang.cod || ' si jobul ' 
                          || v_ang.job || ' are salariul ' || v_ang.salariu);
END;
/

--b) cu date reale
DECLARE
    TYPE emp_record IS RECORD
        (cod      employees.employee_id%TYPE,
         salariu  employees.salary%TYPE,
         job      employees.job_id%TYPE);
    v_ang emp_record;
BEGIN 
    SELECT employee_id, salary, job_id
    INTO v_ang
    FROM employees
    WHERE employee_id = 101;
    DBMS_OUTPUT.PUT_LINE ('Angajatul cu codul '|| v_ang.cod ||
    ' si jobul ' || v_ang.job || ' are salariul ' || v_ang.salariu);
END;
/

--c) stergem datele
DECLARE
    TYPE emp_record IS RECORD
        (cod      employees.employee_id%TYPE,
         salariu  employees.salary%TYPE,
         job      employees.job_id%TYPE);
    v_ang emp_record;
BEGIN
    DELETE FROM emp_mam
    WHERE employee_id=100
    RETURNING employee_id, salary, job_id INTO v_ang;
    DBMS_OUTPUT.PUT_LINE ('Angajatul cu codul '|| v_ang.cod ||
    ' si jobul ' || v_ang.job || ' are salariul ' || v_ang.salariu);
END;
/
ROLLBACK;

--#3 rowtype
DECLARE
    v_ang1 employees%ROWTYPE;
    v_ang2 employees%ROWTYPE;
BEGIN
    --sterg angajat 101 si mentin in variabila linia stearsa
    DELETE FROM emp_mam
    WHERE employee_id = 101
    RETURNING employee_id, first_name, last_name, email, phone_number,
              hire_date, job_id, salary, commission_pct, manager_id,
              department_id
    INTO v_ang1;
    --inserez in tabel linia stearsa
    INSERT INTO emp_mam
    VALUES v_ang1;
    
    --sterg angajat 102 si mentin in variabila linia stearsa
    DELETE FROM emp_mam
    WHERE employee_id = 102
    RETURNING employee_id, first_name, last_name, email, phone_number,
              hire_date, job_id, salary, commission_pct, manager_id,
              department_id
    INTO v_ang2;
    
    --creez o noua linie
    INSERT INTO emp_mam
    VALUES(1000,'FN','LN','E',null,sysdate, 'AD_VP',1000, null,100,90);
    
    --modific noua linie adaugata anterior
    UPDATE emp_mam
    SET ROW = v_ang2
    WHERE employee_id = 1000;
END;
/

--#4 definiti un tablou indexat de numere. Introduceti in 
--acest tablou primele 10 numere naturale
DECLARE
     TYPE tablou_indexat IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
     t tablou_indexat;
BEGIN 
    --a) afisati numarul de elemente al 
    -- tabloului si elementele acestuia
    FOR i IN 1..10 LOOP
        t(i) := i;
    END LOOP;
    DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT || ' elemente: ');
    FOR i IN t.FIRST..t.LAST LOOP
        DBMS_OUTPUT.PUT(t(i) || ' ');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    --b) setati la valoarea null elementele de pe pozitii impare
    --afisati nr de elemente al tabloului si elementele acestuia
    FOR i IN 1..10 LOOP
        IF MOD(i, 2) = 1 
            THEN t(i) := null;
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT('Nr de elem ' || t.COUNT || ' elemente: ');
    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT(t(i) || ' ');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    --c) stergeti primul element, elementele de pe poz 5, 6, 7,
    --respectiv ultimul elemnt afisati val si indicele primului
    --si al ultimului element, dupa afisam elem tabloului si nr lor
    t.DELETE(t.first);
    t.DELETE(5,7);
    t.DELETE(t.last);
    DBMS_OUTPUT.PUT_LINE('Primul element are indicele ' || t.first ||
    ' si valoarea ' || nvl(t(t.first),0));
    DBMS_OUTPUT.PUT_LINE('Ultimul element are indicele ' || t.last ||
    ' si valoarea ' || nvl(t(t.last),0));
    DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
    FOR i IN t.FIRST..t.LAST LOOP
        IF t.EXISTS(i) THEN
            DBMS_OUTPUT.PUT(nvl(t(i), 0)|| ' ');
        END IF;
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    --d) stergeti toate elementele tabloului
    t.DELETE;
    DBMS_OUTPUT.PUT_LINE('Tabloul are ' || t.COUNT ||' elemente.');
END;
/

--#5 definiti un tablou indexat de inregistrati avand tipul celor
--din tabelu emp_**. stergeti primele 2 linii. afisati elem tabloului
--folosing tabelul indexat adaugati inapoi cele doua linii sterse
DECLARE 
    TYPE tablou_indexat IS TABLE OF emp_mam%ROWTYPE INDEX BY BINARY_INTEGER;
    t tablou_indexat;
BEGIN
    --de ce nu merge asa?!
    --SELECT employee_id, first_name, last_name, email, phone_number,
    --       hire_date, job_id, salary, commission_pct, manager_id,
    --       department_id
    --FROM emp_mam
    --INTO t(1)
    --WHERE ROWNUM = 1;
    DELETE FROM emp_mam
    WHERE ROWNUM <= 2
    RETURNING employee_id, first_name, last_name, email, phone_number,
              hire_date, job_id, salary, commission_pct, manager_id,
              department_id
    BULK COLLECT INTO t;
    
    --afisare elemente tablou
    DBMS_OUTPUT.PUT_LINE (t(1).employee_id ||' ' || t(1).last_name);
    DBMS_OUTPUT.PUT_LINE (t(2).employee_id ||' ' || t(2).last_name);
    
    --inserare cele 2 linii in tabel
    INSERT INTO emp_mam VALUES t(1);
    INSERT INTO emp_mam VALUES t(2);
END;
/

--#6 rezolvati exercitiul 4 folosind tablouri imbricate. Introduceti in 
--acest tablou primele 10 numere naturale
DECLARE
    TYPE tablou_imbricat IS TABLE OF NUMBER;
    t tablou_imbricat := tablou_imbricat(); --constructor
BEGIN
    --a) afisati numarul de elemente al 
    -- tabloului si elementele acestuia
    FOR i IN 1..10 LOOP
        t.extend;
        t(i) := i;
    END LOOP;
    DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT || ' elemente: ');
        FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT(t(i) || ' ');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    --b) setati la valoarea null elementele de pe pozitii impare
    --afisati nr de elemente al tabloului si elementele acestuia
    FOR i IN 1..10 LOOP
        IF i mod 2 = 1 THEN t(i) := null;
        END IF;
    END LOOP;

    DBMS_OUPUT.PUT('Nr de elem: ' || t.COUNT  || ' iar elem sunt: ');
    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT(t(i) || ' ');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE();
    --c) stergeti primul element, elementele de pe poz 5, 6, 7,
    --respectiv ultimul elemnt afisati val si indicele primului
    --si al ultimului element, dupa afisam elem tabloului si nr lor
    t.DELETE(t.first);
    t.DELETE(5,7);
    t.DELETE(t.last);
    DBMS_OUTPUT.PUT_LINE('Primul element are indicele ' || t.first ||
    ' si valoarea ' || nvl(t(t.first),0));
    DBMS_OUTPUT.PUT_LINE('Ultimul element are indicele ' || t.last ||
    ' si valoarea ' || nvl(t(t.last),0));
    DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
    FOR i IN t.FIRST..t.LAST LOOP
    IF t.EXISTS(i) THEN
    DBMS_OUTPUT.PUT(nvl(t(i), 0)|| ' ');
    END IF;
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    --d) stergeti toate elementele tabloului
    t.delete;
    DBMS_OUTPUT.PUT_LINE('Tabloul are ' || t.COUNT ||' elemente.');
END;
/

--#7 declarati un tip tablou imbricat de caractere si o variabile de acest tip
--initializati variabile cu urmatoarele valori: m, i,n, i, m. afisati continutul
--tabloului, de la primul la ultimul element si invers. setergeti 2 si 4 apoi
--afisati continutul tabloului

--dupa ce sterg din elemente nu mai merge countul
DECLARE 
    TYPE tablou_imbricat IS TABLE OF CHAR(1);
    t tablou_imbricat := tablou_imbricat('m','i','n','i','a');
    i INTEGER;
BEGIN 
    --initializam tabloul imbricat cu m i n i m
    FOR i IN 1..t.COUNT LOOP
    DBMS_OUTPUT.PUT(t(i) || '');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    
    FOR i IN REVERSE 1..t.COUNT LOOP
    DBMS_OUTPUT.PUT(t(i) || '');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    
    t.delete(2);
    t.delete(4);
    
    DBMS_OUTPUT.PUT_LINE(t.FIRST);
    DBMS_OUTPUT.PUT_LINE(t.LAST);

    
    i := t.FIRST;
    WHILE i <= t.LAST LOOP
        DBMS_OUTPUT.PUT(t(i));
        i := t.NEXT(i);
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    
    i := t.LAST;
    WHILE i >= t.FIRST LOOP
        DBMS_OUTPUT.PUT(t(i));
        i := t.PRIOR(i);
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
END;
/

--cum a facut profa
DECLARE
    TYPE tablou_imbricat IS TABLE OF CHAR(1);
    t tablou_imbricat := tablou_imbricat('m', 'i', 'n', 'i', 'm');
    i INTEGER;
BEGIN
    i := t.FIRST;
    WHILE i <= t.LAST LOOP
        DBMS_OUTPUT.PUT(t(i));
        i := t.NEXT(i);
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    
    i := t.LAST;
    WHILE i >= t.FIRST LOOP
        DBMS_OUTPUT.PUT(t(i));
        i := t.PRIOR(i);
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    
    t.delete(2);
    t.delete(4);
    
    i := t.FIRST;
    WHILE i <= t.LAST LOOP
        DBMS_OUTPUT.PUT(t(i));
        i := t.NEXT(i);
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    
    i := t.LAST;
    WHILE i >= t.FIRST LOOP
        DBMS_OUTPUT.PUT(t(i));
        i := t.PRIOR(i);
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
END;
/

--#8rezolvati ex 4 folosind vectori
DECLARE
    TYPE vector IS VARRAY(10) OF NUMBER;
    t vector:= vector();
BEGIN
    --a) afisati numarul de elemente al 
    -- tabloului si elementele acestuia
    FOR i IN 1..10 LOOP
        t.extend();
        t(i) := i;
    END LOOP;
    
    DBMS_OUTPUT.PUT('nr elem: ' || t.COUNT || ' cu elem: ');
    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT(t(i) || ' ');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    --b) setati la valoarea null elementele de pe pozitii impare
    --afisati nr de elemente al tabloului si elementele acestuia
    FOR i IN 1..10 LOOP
        IF i mod 2 = 1
         THEN t(i) := null;
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT('nr elem: ' || t.COUNT || ' cu elem: ');
    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT(t(i) || ' ');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    --c) stergeti primul element, elementele de pe poz 5, 6, 7,
    --respectiv ultimul elemnt afisati val si indicele primului
    --si al ultimului element, dupa afisam elem tabloului si nr lor

    --in array ori stergi tot ori nimic, nu poti sterge elemente individuale
    -- metodele DELETE(n), DELETE(m,n) nu sunt valabile pentru vectori!!!
    -- din vectori nu se pot sterge elemente individuale!!!

    --d) stergeti toate elementele tabloului
    t.DELETE();
    DBMS_OUTPUT.PUT('nr elem: ' || t.COUNT || ' cu elem: ');
    DBMS_OUTPUT.NEW_LINE;
END;
/

--#9 definiti tipul subordonati_mam vector cu dim max 10 cu numere bla bla
--Creați tabelul manageri_*** cu următoarele câmpuri: cod_mgr NUMBER(10), 
--nume VARCHAR2(20), lista subordonati_***. Introduceți 3 linii în tabel. 
--Afișați informațiile din tabel. Ștergeți tabelul creat, apoi tipul.
CREATE OR REPLACE TYPE subordonati_mam AS VARRAY(10) OF NUMBER(4);
/
CREATE TABLE manageri_mam ( cod_mgr Number(10),
                            nume    VARCHAR2(20),
                            lista   subordonati_mam
                         );
                         
DECLARE
    v_sub subordonati_mam := subordonati_mam(100,200,300);
    v_lista manageri_mam.lista%TYPE;
BEGIN
    INSERT INTO manageri_mam
    VALUES (1, 'Mgr 1', v_sub);
    
    INSERT INTO manageri_mam
    VALUES (2, 'Mgr 2', null);
    
    INSERT INTO manageri_mam
    VALUES (3, 'Mgr 3', subordonati_mam(400,500));
    
    SELECT lista
    INTO v_lista
    FROM manageri_mam
    WHERE cod_mgr = 1;
    
    FOR j IN v_lista.FIRST..v_lista.LAST loop
    DBMS_OUTPUT.PUT_LINE (v_lista(j));
    END LOOP;
END;
/
SELECT * FROM manageri_mam;
DROP TABLE manageri_mam;
DROP TYPE subordonati_mam;

--#10 Creați tabelul emp_test_*** cu coloanele employee_id și last_name din 
--tabelul employees. Adăugați în acest tabel un nou câmp numit telefon de tip 
--tablou imbricat. Acest tablou va menține pentru fiecare salariat toate numerele 
--de telefon la care poate fi contactat. Inserați o linie nouă în tabel. Actualizați 
--o linie din tabel. Afișați informațiile din tabel. Ștergeți tabelul și tipul.
CREATE TABLE emp_test_mam AS
    SELECT employee_id, last_name FROM employees
    WHERE ROWNUM <= 2;

CREATE OR REPLACE TYPE tip_telefon_mam IS TABLE OF VARCHAR(12);
/    

ALTER TABLE emp_test_mam
ADD (telefon tip_telefon_mam)
NESTED TABLE telefon STORE AS tabel_telefon_mam;

INSERT INTO emp_test_mam
VALUES (500, 'XYZ',tip_telefon_mam('074XXX', '0213XXX', '037XXX'));
UPDATE emp_test_mam
SET telefon = tip_telefon_mam('073XXX', '0214XXX')
WHERE employee_id=100;
SELECT a.employee_id, b.*
FROM emp_test_mam a, TABLE (a.telefon) b;
DROP TABLE emp_test_mam;
DROP TYPE tip_telefon_mam;

--#11 Ștergeți din tabelul emp_*** salariații având 
-- codurile menținute într-un vector.
DECLARE
    TYPE tip_cod IS VARRAY(5) OF NUMBER(3);
    coduri tip_cod := tip_cod(205,206);
BEGIN
    FOR i IN coduri.FIRST..coduri.LAST LOOP
        DELETE FROM emp_mam
        WHERE employee_id = coduri (i);
    END LOOP;
END;
/
SELECT employee_id FROM emp_mam;
ROLLBACK;

DECLARE
    TYPE tip_cod IS VARRAY(20) OF NUMBER;
    coduri tip_cod := tip_cod(205,206);
BEGIN
    FORALL i IN coduri.FIRST..coduri.LAST
    DELETE FROM emp_mam
    WHERE employee_id = coduri (i);
END;
/
SELECT employee_id FROM emp_***;
ROLLBACK;