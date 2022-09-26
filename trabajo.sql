CREATE TABLE cooperativa(

codigo NUMBER(8) PRIMARY KEY,

nombre VARCHAR2(30) NOT NULL UNIQUE,

c_acumulado NUMBER(8)

);

CREATE OR REPLACE TRIGGER before_insert_cooperativa
BEFORE INSERT
  on cooperativa
  FOR EACH ROW 
BEGIN
  IF(:NEW.c_acumulado != 0 OR :NEW.c_acumulado is null) THEN
    :NEW.c_acumulado := 0;
  END IF;  
END;

CREATE TABLE socio(

idsocio NUMBER(8) PRIMARY KEY,

nombre VARCHAR2(30) NOT NULL,

s_acumulado NUMBER(11,3) CHECK(s_acumulado >= 0)

);

CREATE OR REPLACE TRIGGER before_insert_socio
BEFORE INSERT
  on socio
  FOR EACH ROW 
BEGIN
  IF(:NEW.s_acumulado != 0 OR :NEW.s_acumulado is null) THEN
    :NEW.s_acumulado := 0;
  END IF;  
END;

/* Procedimiento 2 PL/SQL */

CREATE OR REPLACE PROCEDURE consulta_socio
(id_socio IN socio.idsocio%TYPE) IS
datos_socio socio%ROWTYPE;
num_participacion NUMBER(5);
nom_coope cooperativa.nombre%TYPE;
count_coopes NUMBER(5) := 1;
count_no_coopes NUMBER(5) := 1;
BEGIN
    SELECT * INTO datos_socio FROM socio WHERE idsocio = id_socio;
    SELECT COUNT(*) INTO num_participacion FROM coopexsocio WHERE socio = id_socio GROUP BY socio; 
    
    DBMS_OUTPUT.PUT_LINE('Nombre del socio: '|| datos_socio.nombre);
    DBMS_OUTPUT.PUT_LINE('Acumulado del socio: '|| datos_socio.s_acumulado);
    DBMS_OUTPUT.PUT_LINE('Número de cooperativas en las que participa: '|| num_participacion);
    DBMS_OUTPUT.PUT_LINE('Cooperativas del socio:');
    DBMS_OUTPUT.PUT_LINE('{');
    FOR iter_coope IN (SELECT * FROM coopexsocio WHERE socio = id_socio) LOOP
        SELECT nombre INTO nom_coope FROM cooperativa WHERE codigo = iter_coope.coope;
        DBMS_OUTPUT.PUT_LINE(count_coopes || '. (Nombre: '|| nom_coope || ', Valorsc: ' || iter_coope.sc_acumulado || ')');
        count_coopes := count_coopes + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('}');
    DBMS_OUTPUT.PUT_LINE('Cooperativas en las que no está el socio:');
    DBMS_OUTPUT.PUT_LINE('{');
    FOR iter_coope IN (SELECT * FROM (SELECT * FROM coopexsocio WHERE socio = id_socio) coopes_socio RIGHT JOIN cooperativa 
    ON coopes_socio.coope = cooperativa.codigo WHERE coopes_socio.coope IS NULL) 
    LOOP
        nom_coope := iter_coope.nombre;
        DBMS_OUTPUT.PUT_LINE(count_no_coopes || '. '|| nom_coope);
        count_no_coopes := count_no_coopes + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('}');
END;