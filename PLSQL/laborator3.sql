--#1 Ob?ine?i pentru fiecare departament numele acestuia ?i num?rul de angaja?i
DECLARE 
    v_nr number(4);
    v_nume departments.department_name%TYPE;
    CURSOR c IS
        SELECT department_name, COUNT(employee_id)
        FROM   departments d, employees e
        WHERE  d.department_id = e.department_id(+)
        GROUP BY department_name;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO v_nume, v_nr;
        EXIT WHEN c%NOTFOUND;
        IF v_nr=0 THEN
            DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||
            ' nu lucreaza angajati');
        ELSIF v_nr=1 THEN
            DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||
            ' lucreaza un angajat');
        ELSE
            DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||
            ' lucreaza '|| v_nr||' angajati'); 
        END IF;
    END LOOP;
    CLOSE c;
END;

--#2 Rezolva?i exerci?iul 1 men?inând informa?iile din cursor în colec?ii.
DECLARE
    TYPE tip_lista_nr IS TABLE OF NUMBER(4);
    TYPE tip_lista_nume IS TABLE OF departments.department_name%TYPE;
    lista_nr   tip_lista_nr   := tip_lista_nr();
    lista_nume tip_lista_nume := tip_lista_nume();
    CURSOR c IS
        SELECT department_name, COUNT(employee_id)
        FROM departments d, employees e
        WHERE d.department_id = e.department_id(+)
        GROUP BY department_name;
BEGIN
    OPEN c;
        FETCH c BULK COLLECT INTO lista_nume, lista_nr;    
    CLOSE c;
    FOR i IN lista_nume.FIRST..lista_nume.LAST LOOP
        IF lista_nr(i) = 0 THEN
            DBMS_OUTPUT.PUT_LINE('In departamentul '|| lista_nume(i)||
                ' nu lucreaza angajati');
        ELSIF lista_nr(i) = 1 THEN
            DBMS_OUTPUT.PUT_LINE('In departamentul '|| lista_nume(i)||
                ' lucreaza un angajat');
        ELSE
            DBMS_OUTPUT.PUT_LINE('In departamentul '|| lista_nume(i)||
                ' lucreaza '|| lista_nr(i)||' angajati');
        END IF;
    END LOOP;
END;
/

--#3 rezolvare exercitiul 1 cu ciclu cursor
DECLARE
    CURSOR c IS
    SELECT department_name, COUNT(employee_id) nr
    FROM departments d, employees e
    WHERE d.department_id=e.department_id(+)
    GROUP BY department_name;
BEGIN
    FOR i in c LOOP
        IF i.nr=0 THEN
            DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.department_name||
            ' nu lucreaza angajati');
        ELSIF i.nr=1 THEN
            DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.department_name ||
            ' lucreaza un angajat');
        ELSE
            DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.department_name||
            ' lucreaza '|| i.nr||' angajati');
        END IF;
    END LOOP;
END;
/

--#4 rezolvare exercitiu 1 folosind ciclu cursor cu subcereri
BEGIN
    FOR i in ( SELECT department_name, COUNT(employee_id) nr
               FROM departments d, employees e
               WHERE d.department_id=e.department_id(+)
               GROUP BY department_name) LOOP
        IF i.nr=0 THEN
            DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.department_name||
            ' nu lucreaza angajati');
        ELSIF i.nr=1 THEN
            DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.department_name ||
            ' lucreaza un angajat');
        ELSE
            DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.department_name||
            ' lucreaza '|| i.nr||' angajati');
        END IF;
    END LOOP;
END;
/

--#5Ob?ine?i primii 3 manageri care au cei mai mul?i subordona?i.
--Afi?a?i numele managerului, respectiv num?rul de angaja?i.
DECLARE
    v_cod employees.employee_id%TYPE;
    v_nume employees.last_name%TYPE;
    v_nr NUMBER(4);
    CURSOR c IS
        SELECT sef.employee_id cod, MAX(sef.last_name) nume,
        count(*) nr
        FROM employees sef, employees ang
        WHERE ang.manager_id = sef.employee_id
        GROUP BY sef.employee_id
        ORDER BY nr DESC;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO v_cod,v_nume,v_nr;
        EXIT WHEN c%ROWCOUNT>3 OR c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Managerul '|| v_cod ||
        ' avand numele ' || v_nume ||
        ' conduce ' || v_nr||' angajati');
    END LOOP;
    CLOSE c;
END;
/

--#6 ex 5 dar cu ciclu cursor
DECLARE
    v_cod employees.employee_id%TYPE;
    v_nume employees.last_name%TYPE;
    v_nr NUMBER(4);
    CURSOR c IS
        SELECT sef.employee_id cod, MAX(sef.last_name) nume,
        count(*) nr
        FROM employees sef, employees ang
        WHERE ang.manager_id = sef.employee_id
        GROUP BY sef.employee_id
        ORDER BY nr DESC;
BEGIN
    FOR i IN c LOOP
        EXIT WHEN c%ROWCOUNT>3 OR c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Managerul '|| i.cod ||
        ' avand numele ' || i.nume ||
        ' conduce '|| i.nr||' angajati');
    END LOOP;
END;
/

--#7 ex 5 dar cu ciclu cursor cu subcereri
DECLARE
    top number(1):= 0;
BEGIN
    FOR i IN (SELECT sef.employee_id cod, MAX(sef.last_name) nume,
                count(*) nr
                FROM employees sef, employees ang
                WHERE ang.manager_id = sef.employee_id
                GROUP BY sef.employee_id
                ORDER BY nr DESC) LOOP
        DBMS_OUTPUT.PUT_LINE('Managerul '|| i.cod ||
        ' avand numele ' || i.nume ||
        ' conduce '|| i.nr||' angajati');
        Top := top+1;
        EXIT WHEN top=3;
    END LOOP;
END;
/

--#8 ex 1 dar obtinem departamentele in care lucreaza cel putin x (tastatura) aganjati
--cursor clasic
DECLARE 
    v_x number(4) := &p_x;
    v_nr number(4);
    v_nume departments.department_name%TYPE;
    CURSOR c (parametru NUMBER) IS
        SELECT department_name nume, COUNT(employee_id)
        FROM   departments d, employees e
        WHERE  d.department_id = e.department_id(+)
        GROUP BY department_name
        HAVING COUNT(employee_id)> parametru;
BEGIN
    OPEN c(v_x);
    LOOP
        FETCH c INTO v_nume,v_nr;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||
        ' lucreaza '|| v_nr||' angajati');
    END LOOP;
    CLOSE c;
END;

--ciclu cursor
DECLARE 
    v_x  number(4) := &p_x;
    CURSOR c (parametru NUMBER) IS
        SELECT department_name nume, COUNT(employee_id) nr
        FROM   departments d, employees e
        WHERE  d.department_id = e.department_id
        GROUP BY department_name
        HAVING COUNT(employee_id)> parametru;
BEGIN
    FOR i in c(v_x) LOOP
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
            ' lucreaza '|| i.nr||' angajati');
    END LOOP;
END;

DECLARE 
    v_x  number(4) := &p_x;
BEGIN
    FOR i in (
        SELECT department_name name, COUNT(employee_id) nr
        FROM   departments d, employees e
        WHERE  d.department_id = e.department_id
        GROUP BY department_name
        HAVING COUNT(employee_id)> v_x) LOOP
         DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
            ' lucreaza '|| i.nr||' angajati');
    END LOOP;
END;


--#9 mariti cu 1000 de lei salariile angajatilor de anul 2000
DECLARE
    CURSOR c IS
    SELECT *
    FROM emp_mam
    WHERE TO_CHAR(hire_date, 'YYYY') = 2000
    FOR UPDATE OF salary NOWAIT;
BEGIN
    FOR i IN c LOOP
        UPDATE emp_mam
        SET salary= salary+1000
        WHERE CURRENT OF c;
    END LOOP;
END;
/

--#10 pentru fiecare dintre departamentele 10, 20, 30 si 40
--obtineti numele precum si lista numelor angajatilor care isi desfasoara
--activitatea in cadrul acestora
DECLARE
    v_id employees.employee_id%TYPE;
    v_nume employees.first_name%TYPE;
    CURSOR c IS
        SELECT employee_id e_id, first_name e_name
        FROM employees e
        WHERE e.department_id = 10 OR 
              e.department_id = 20 OR  
              e.department_id = 30 OR 
              e.department_id = 40;
BEGIN
    OPEN c;
        LOOP
            FETCH c INTO v_id, v_nume;
            EXIT WHEN c%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE(v_id || v_nume);
        END LOOP;
    CLOSE c;
END;
/

DECLARE
    v_id employees.employee_id%TYPE;
    v_nume employees.first_name%TYPE;
    CURSOR c IS
        SELECT employee_id e_id, first_name e_name
        FROM employees e
        WHERE e.department_id = 10 OR 
              e.department_id = 20 OR  
              e.department_id = 30 OR 
              e.department_id = 40;
BEGIN
    FOR i IN c LOOP
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(i.employee_id || i.first_name);
    END LOOP;
END;
/

BEGIN
FOR v_dept IN (SELECT department_id, department_name
FROM departments

WHERE department_id IN (10,20,30,40))

LOOP
DBMS_OUTPUT.PUT_LINE('-------------------------------------');
DBMS_OUTPUT.PUT_LINE ('DEPARTAMENT '||v_dept.department_name);
DBMS_OUTPUT.PUT_LINE('-------------------------------------');
FOR v_emp IN (SELECT last_name
FROM employees

WHERE department_id = v_dept.department_id)

LOOP
DBMS_OUTPUT.PUT_LINE (v_emp.last_name);
END LOOP;
END LOOP;
END;
/