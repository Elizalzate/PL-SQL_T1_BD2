/* Creación de tablas */

CREATE TABLE cooperativa(
    codigo NUMBER(8) PRIMARY KEY,
    nombre VARCHAR2(30) NOT NULL UNIQUE,
    c_acumulado NUMBER(8)
);

CREATE TABLE socio(
    idsocio NUMBER(8) PRIMARY KEY,
    nombre VARCHAR2(30) NOT NULL,
    s_acumulado NUMBER(11,3) CHECK(s_acumulado >= 0)
);

CREATE TABLE coopexsocio(
    socio NUMBER(8) REFERENCES socio,
    coope NUMBER(11, 3) REFERENCES cooperativa,
    PRIMARY KEY(socio, coope),
    sc_acumulado NUMBER(8,3)
);

/* Trigger de insercion 1: (3%) */

CREATE OR REPLACE TRIGGER before_insert_cooperativa
BEFORE INSERT
  ON cooperativa
  FOR EACH ROW 
BEGIN
  IF(:NEW.c_acumulado != 0 OR :NEW.c_acumulado is null) THEN
    :NEW.c_acumulado := 0;
  END IF;  
END;

/* Trigger de insercion 2: (3%) */

CREATE OR REPLACE TRIGGER before_insert_socio
BEFORE INSERT
  ON socio
  FOR EACH ROW 
BEGIN
  IF(:NEW.s_acumulado != 0 OR :NEW.s_acumulado is null) THEN
    :NEW.s_acumulado := 0;
  END IF;  
END;
 
/* Trigger de inserción 3: (3%) */
CREATE OR REPLACE TRIGGER before_insert_coopexsocio
BEFORE INSERT
  ON coopexsocio
  FOR EACH ROW 
BEGIN
  IF(:NEW.sc_acumulado != 0 OR :NEW.sc_acumulado is null) THEN
    :NEW.sc_acumulado := 0;
  END IF;  

END;

/* Trigger de borrado sobre cooperativa: (15%) */

CREATE OR REPLACE TRIGGER after_delete_cooperativa
AFTER DELETE 
    ON cooperativa
    FOR EACH ROW
DECLARE
    CURSOR coopexsocio_c IS SELECT * FROM coopexsocio WHERE coope = :OLD.codigo;
BEGIN
    FOR iter IN coopexsocio_c LOOP
        UPDATE socio SET s_acumulado = s_acumulado - iter.sc_acumulado WHERE idsocio = iter.socio;
    END LOOP;
    DELETE FROM coopexsocio WHERE coope = :OLD.codigo;  
END;

/* Trigger de borrado sobre la tabla socio: (10%) */

CREATE OR REPLACE TRIGGER after_delete_socio
AFTER DELETE 
    ON socio
    FOR EACH ROW
BEGIN
    DELETE FROM coopexsocio WHERE socio = :OLD.idsocio;
END;

/* Programa 1 PL/SQL */

CREATE OR REPLACE PROCEDURE consulta_cooperativa 
(cod_coope IN cooperativa.codigo%TYPE) IS
CURSOR socios_coope IS SELECT socio, sc_acumulado FROM coopexsocio WHERE coope = cod_coope;
datos_cooperativa cooperativa%ROWTYPE;
nom_socio socio.nombre%TYPE;
count_socios NUMBER(5) := 1;
num_socios NUMBER(8);
total_valores NUMBER(8,3);
BEGIN
    SELECT * INTO datos_cooperativa FROM cooperativa WHERE codigo = cod_coope;
    SELECT COUNT(*) INTO num_socios FROM coopexsocio WHERE coope = cod_coope GROUP BY coope;
    SELECT SUM(sc_acumulado) INTO total_valores FROM coopexsocio WHERE coope = cod_coope GROUP BY coope;
    DBMS_OUTPUT.PUT_LINE('Nombre de la cooperativa: '|| datos_cooperativa.nombre);
    DBMS_OUTPUT.PUT_LINE('Acumulado de la cooperativa: '|| datos_cooperativa.c_acumulado);
    DBMS_OUTPUT.PUT_LINE('Número de socios: '|| num_socios);
    DBMS_OUTPUT.PUT_LINE('Socios de la cooperativa:');
    DBMS_OUTPUT.PUT_LINE('{');
    FOR iter_socio IN socios_coope LOOP
        SELECT nombre INTO nom_socio FROM socio WHERE idsocio = iter_socio.socio;
        DBMS_OUTPUT.PUT_LINE(count_socios || '. (Nombre: '|| nom_socio || ', Valorsc: ' || iter_socio.sc_acumulado || ')');
        count_socios := count_socios + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('}');
    DBMS_OUTPUT.PUT_LINE('Total valores de los socios en la cooperativa: '|| total_valores);
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
