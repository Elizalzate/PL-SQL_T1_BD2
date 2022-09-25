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
END;