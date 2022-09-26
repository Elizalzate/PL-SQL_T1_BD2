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

INSERT INTO cooperativa VALUES (1,'Faithless', 100);
INSERT INTO cooperativa VALUES (2,'Vía lactea', 3000);
INSERT INTO cooperativa VALUES (3,'Olímpica', -6);
INSERT INTO cooperativa VALUES (4,'El cerdito', 11100);
INSERT INTO cooperativa(codigo, nombre) VALUES (5,'Su vaquita');

SELECT * FROM cooperativa;

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

INSERT INTO socio VALUES (50,'Rhianna Kenny', 100);
INSERT INTO socio VALUES (60,'Kyla La Grange', -3000);
INSERT INTO socio(idsocio, nombre) VALUES (99,'Cass Fox');

SELECT * FROM socio;

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

INSERT INTO coopexsocio VALUES (50,1, 100);
INSERT INTO coopexsocio VALUES (60,2, -3000);
INSERT INTO coopexsocio(socio, coope) VALUES (50,3);

SELECT * FROM coopexsocio;

CREATE OR REPLACE TRIGGER before_update_cooperativa
BEFORE UPDATE
  on cooperativa
  FOR EACH ROW 
DECLARE
    cooperativa NUMBER(8);
    socio NUMBER(8);
    incremento NUMBER(8);
    Nsocios NUMBER(8);
    incrementoxsocio NUMBER(8);
    sc_acumulado NUMBER(8);
    s_acumulado NUMBER(8);
BEGIN
    incremento :=  :NEW.c_acumulado - :OLD.c_acumulado;
    DBMS_OUTPUT.PUT_LINE(incremento);  
END;

INSERT INTO cooperativa VALUES (1, 'Faithless', 2000);
INSERT INTO cooperativa VALUES (4, 'El Cerdito', 12000);
INSERT INTO cooperativa VALUES (5, 'Su vaquita', -2000);

INSERT INTO socio VALUES (50, 'Rhianna Kenny', 5500);
INSERT INTO socio VALUES (60, 'Kyla LaGrange', 51500);
INSERT INTO socio VALUES (99, 'Cass Fox', 0);

INSERT INTO coopexsocio VALUES (50, 1, 2000);
INSERT INTO coopexsocio VALUES (60, 1, 0);
INSERT INTO coopexsocio VALUES (99, 1, -2000);
INSERT INTO coopexsocio VALUES (60,5, 2000);
INSERT INTO coopexsocio VALUES (99, 5, -12000);