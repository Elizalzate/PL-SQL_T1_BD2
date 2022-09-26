/* Creacion de tablas */

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
  on cooperativa
  FOR EACH ROW 
BEGIN
  IF(:NEW.c_acumulado != 0 OR :NEW.c_acumulado is null) THEN
    :NEW.c_acumulado := 0;
  END IF;  
END;

/* Trigger de insercion 2: (3%) */

CREATE OR REPLACE TRIGGER before_insert_socio
BEFORE INSERT
  on socio
  FOR EACH ROW 
BEGIN
  IF(:NEW.s_acumulado != 0 OR :NEW.s_acumulado is null) THEN
    :NEW.s_acumulado := 0;
  END IF;  
END;


CREATE TABLE coopexsocio(

socio NUMBER(8) REFERENCES socio,

coope NUMBER(11, 3) REFERENCES cooperativa,

PRIMARY KEY(socio, coope),

sc_acumulado NUMBER(8)

);

CREATE OR REPLACE TRIGGER before_insert_coopexsocio
BEFORE INSERT
  on coopexsocio
  FOR EACH ROW 
BEGIN
  IF(:NEW.sc_acumulado != 0 OR :NEW.sc_acumulado is null) THEN
    :NEW.sc_acumulado := 0;
  END IF;  

END;

/* Trigger de borrado sobre cooperativa: (15%) */

CREATE OR REPLACE TRIGGER borrado_cooperativa
AFTER DELETE ON cooperativa
FOR EACH ROW
DECLARE
    CURSOR coopexsocio_c IS SELECT * FROM coopexsocio WHERE coope = :OLD.codigo;
BEGIN
    FOR iter IN coopexsocio_c LOOP
        UPDATE socio SET s_acumulado = s_acumulado - iter.sc_acumulado WHERE idsocio = iter.socio;
    END LOOP;
    DELETE FROM coopexsocio WHERE coope = :OLD.codigo;  
