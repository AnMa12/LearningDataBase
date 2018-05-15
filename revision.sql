

EXCURSIE(#id_excursie, denumire, pret, destinatie, durata, cod_agentie, nr_locuri)
AGENTIE(#id_agentie, denumire, oras)

INSERT INTO TURIST VALUES()

INSERT INTO AGENTIE VALUES(1,'A','OA');
INSERT INTO AGENTIE VALUES(2,'B','OB');
INSERT INTO AGENTIE VALUES(3,'C','OC');
INSERT INTO AGENTIE VALUES(4,'D','OD');

INSERT INTO EXCURSIE VALUES(1, 'EA', 100, 'AO', 7, 1, 75);
INSERT INTO EXCURSIE VALUES(2, 'EB', 143, 'BO', 2, 2, 12);
INSERT INTO EXCURSIE VALUES(3, 'EC', 123, 'CO', 3, 3, 435);
INSERT INTO EXCURSIE VALUES(4, 'ED', 98, 'AO', 4, 3, 321);
INSERT INTO EXCURSIE VALUES(5, 'EE', 178, 'DO', 7, 1, 435);
INSERT INTO EXCURSIE VALUES(6, 'EF', 121, 'FO', 7, 2, 213);
INSERT INTO EXCURSIE VALUES(7, 'EG', 56, 'DO', 4, 1, 34);
INSERT INTO EXCURSIE VALUES(8, 'EH', 98, 'AO', 5, 1, 50);

TURIST(#id_turist, nume, prenume, data_nastere)

INSERT INTO TURIST VALUES(1, 'AN', 'AP', '1997-04-03');
INSERT INTO TURIST VALUES(2, 'BN', 'BP', '1998-04-03');
INSERT INTO TURIST VALUES(3, 'CN', 'CP', '1996-04-03');
INSERT INTO TURIST VALUES(4, 'DN', 'DP', '1997-07-03');

ACHIZITIONEAZA(#cod_turist, #cod_excursie, #data_start, data_end, data_achizitie, discount)
DROP TABLE ACHIZITIONEAZA;
INSERT INTO ACHIZITIONEAZA VALUES(1,1,'2015-12-04','2015-12-04','2015-02-05',1);
INSERT INTO ACHIZITIONEAZA VALUES(2,2,'2015-12-04','2015-12-04','2015-04-05',1);
INSERT INTO ACHIZITIONEAZA VALUES(3,7,'2015-12-04','2015-12-04','2015-01-18',1);
INSERT INTO ACHIZITIONEAZA VALUES(3,8,'2015-12-04','2015-12-04','2015-08-04',1);
INSERT INTO ACHIZITIONEAZA VALUES(2,5,'2015-12-04','2015-12-04','2016-01-05',1);
INSERT INTO ACHIZITIONEAZA VALUES(4,3,'2015-12-04','2015-12-04','2015-01-18',1);
INSERT INTO ACHIZITIONEAZA VALUES(1,2,'2015-12-04','2015-12-04','2015-08-04',1);
INSERT INTO ACHIZITIONEAZA VALUES(2,1,'2015-12-04','2015-12-04','2016-01-05',1);
INSERT INTO ACHIZITIONEAZA VALUES(1,4,'2015-12-04','2015-12-04','2016-01-05',1);
INSERT INTO ACHIZITIONEAZA VALUES(4,4,'2015-12-04','2015-12-04','2016-01-05',1);
/*1. Sa se afiseze denumirea primei excursii achizitionate.
trebuie sa sortam dupa data_achizitie si sa afisam doar prima valoare*/
SELECT cod_turist, data_achizitie AS primaAchizitie
FROM ACHIZITIONEAZA
ORDER BY data_achizitie
LIMIT 1;

/*2. Afisati de câte ori a fost achizitionata fiecare excursie.
SELECT cod_excursie, COUNT(cod_excursie) AS numarAparitii
FROM ACHIZITIONEAZA;*/
SELECT cod_excursie, COUNT(*) AS numarAchizitionari
FROM ACHIZITIONEAZA
GROUP BY cod_excursie;

TURIST(#id_turist, nume, prenume, data_nastere)
ACHIZITIONEAZA(#cod_turist, #cod_excursie, #data_start, data_end, data_achizitie,
discount)
EXCURSIE(#id_excursie, denumire, pret, destinatie, durata, cod_agentie, nr_locuri)
AGENTIE(#id_agentie, denumire, oras)

/*3. Sa se afiseze pentru fiecare agentie, denumirea, orasul, numarul de excursii oferite,
media preturilor excursiilor oferite.
SELECT AGENTIE.denumire, AGENTIE.oras
COUNT(*) AS numarExcursiiOferite, 
FROM AGENTIE JOIN EXCURSIE
ON AGENTIE.id_agentie = EXCURSIE.cod_agentie
GROUP BY id_agentie;*/
SELECT AGENTIE.denumire, 
       AGENTIE.oras, 
       COUNT(id_excursie) as nrExcursii,
       AVG(pret) as mediePreturi
FROM AGENTIE JOIN EXCURSIE
ON AGENTIE.id_agentie = EXCURSIE.cod_agentie
GROUP BY denumire;

/*SELECT TURIST.nume, TURIST.prenume , COUNT(cod_excursie) as excursiiAchizitionte
FROM TURIST JOIN ACHIZITIONEAZA
ON TURIST.id_turist = ACHIZITIONEAZA.cod_turist
GROUP BY TURIST.nume
WHERE excursiiAchizitionte >= 2;
4. a. Sa se obtina numele si prenumele turistilor care au achizitionat cel putin 2 excursii.*/
SELECT TURIST.nume, TURIST.prenume
FROM TURIST JOIN ACHIZITIONEAZA
ON TURIST.id_turist = ACHIZITIONEAZA.cod_turist
GROUP BY TURIST.nume
HAVING COUNT(cod_excursie) >= 2;

/*b. ???Sa se obNina numarul turistilor care au achiziNionat cel putin 2 excursii.*/
SELECT COUNT

/*5. AfisaNi informaNii despre turistii care nu au achiziNionat excursii cu destinaNia AO.*/
SELECT DISTINCT TURIST.nume, TURIST.prenume, TURIST.data_nastere
FROM TURIST JOIN ACHIZITIONEAZA
ON TURIST.id_turist = ACHIZITIONEAZA.cod_turist
JOIN EXCURSIE
ON ACHIZITIONEAZA.cod_excursie = EXCURSIE.id_excursie
WHERE EXCURSIE.destinatie = 'AO';


6. AfisaNi codul si numele turistilor care au achiziNionat excursii spre cel puNin doua
destinaNii diferite.
7. Sa se afiseze pentru fiecare agenNie, denumirea si profitul obNinut. (Profitul obNinut din
vânzarea unei excursii este pret – pret * discount Daca discountul este necunoscut
profitul este preNul excursiei).
8. Sa se afiseze denumirea si orasul pentru agenNiile care au cel puNin 3 excusii oferite la
un preN mai mic decat 2000 euro.
9. Sa se afiseze excursiile care nu au fost achiziNionate de catre nici un turist.
10. AfisaNi informaNii despre excursii, inclusiv denumirea agenNiei. Pentru excursiile
pentru care nu este cunoscuta agenNia se va afisa textul “agentie necunoscuta”.
11. Sa se afiseze informaNii despre excursiile care au preNul mai mare decat excursia cu
denumirea “Orasul luminilor” existenta în oferta agenNiei cu codul 10.
12. Sa se obNina lista turistilor care au achiziNionat excursii cu o durata mai mare de 10
zile. (se va lua în considerare data_start si data_end)
13. Sa se obNina excusiile achiziNionate de cel puNin un turist vârsta mai mica de 30 de ani.
14. Sa se obNina turistii care nu au achiziNionat nicio excursie oferita de agenNii din
Bucuresti.
15. Sa se obNina numele turistilor care au achiziNionat excursii care conNin în denumire “1
mai” de la o agenNie din Bucuresti.
16. Sa se obNina numele, prenume turistilor si excursiile oferite de agenNia “Smart Tour”
achiziNionate de catre acestia.
17. Sa se afiseze excursiile pentru care nu mai exista locuri pentru data de plecare 14 -
aug-2011.
18. Sa se obNina codurile turistilor si codul ultimei excursii achiziNionate de catre acestia.
19. AfisaNi topul celor mai scumpe excursii (primele 5).
20. AfisaNi numele turistilor care au achiziNionat excursii cu data de plecare în aceeasi
luna cu luna în care îsi serbeaza ziua de nastere. 
21. Sa se afiseze informaNii despre turistii care au achiziNionat excusii de 2 persoane de la
agenNii din ConstanNa.
22. În funcNie de durata excursiei afisaNi în ordine excursiile cu durata mica (durata de
maxim 5 zile), medie (durata între 6 si 19 de zile), lunga (durata peste 20 de zile).
23. AfisaNi numarul excursiilor, câte excursii sunt oferite de agenNii din ConstanNa, câte
sunt oferite de agenNii din Bucuresti.
Numar excursii Nr. ex Constanta Nr. ex Bucuresti
-------------------------------------------------------------
24. AfisaNi excursiile care au fost achiziNionate de toNi turistii în vârsta de 24 ani.
25. AfisaNi valoarea totala a excursiilor:
-Pentru fiecare agenNie si în cadrul agenNiei pentru fiecare destinaNie.
-Pentru fiecare agenNi (indiferent de destinaNie)
-Întreg tabelul.
AfisaNi o coloana care se indice intervenNia celorlalte coloane în obNinerea rezultatului.
26. Sa se obNina pentru fiecare agenNie media preNurilor excursiilor oferite de agenNiile
concurente (situate în acelasi oras). 

INSERT INTO ACHIZITIONEAZA VALUES(1,1,'2015-12-04','2015-12-04','2015-02-05',1);
INSERT INTO ACHIZITIONEAZA VALUES(2,1,'2015-12-04','2015-12-04','2015-04-05',1);
INSERT INTO ACHIZITIONEAZA VALUES(3,1,'2015-12-04','2015-12-04','2015-01-18',1);
INSERT INTO ACHIZITIONEAZA VALUES(4,1,'2015-12-04','2015-12-04','2015-08-04',1);
INSERT INTO ACHIZITIONEAZA VALUES(5,1,'2015-12-04','2015-12-04','2016-01-05',1);
INSERT INTO ACHIZITIONEAZA VALUES(6,2,'2015-12-04','2015-12-04','2015-01-18',1);
INSERT INTO ACHIZITIONEAZA VALUES(7,2,'2015-12-04','2015-12-04','2015-08-04',1);
INSERT INTO ACHIZITIONEAZA VALUES(8,3,'2015-12-04','2015-12-04','2016-01-05',1);

DROP TABLE AGENTIE
CREATE TABLE AGENTIE (
    id_agentie INT NOT NULL,
    denumire varchar(40) NOT NULL,
    oras varchar(40) NOT NULL,
    PRIMARY KEY(id_agentie)
);

CREATE TABLE EXCURSIE (
    id_excursie INT NOT NULL,
    denumire varchar(40) NOT NULL,
    pret INT NOT NULL,
    destinatie varchar(40) NOT NULL,
    durata INT NOT NULL,
    cod_agentie INT NOT NULL,
    nr_locuri INT NOT NULL,
    PRIMARY KEY(id_excursie)
);

CREATE TABLE TURIST(
    id_turist INT NOT NULL,
    nume varchar(40) NOT NULL,
    prenume varchar(40) NOT NULL,
    data_nastere DATE NOT NULL,
    PRIMARY KEY(id_turist)
);

CREATE TABLE ACHIZITIONEAZA(
    cod_turist INT NOT NULL,
    cod_excursie INT NOT NULL,
    data_start DATE NOT NULL,
    data_end DATE NOT NULL,
    data_achizitie DATE NOT NULL,
    discount INT NOT NULL
);