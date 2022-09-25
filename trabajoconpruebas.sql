CREATE TABLE cooperativa(

codigo NUMBER(8) PRIMARY KEY,

nombre VARCHAR2(30) NOT NULL UNIQUE,

c_acumulado NUMBER(8)

);

CREATE OR REPLACE TRIGGER after_insert_cooperativa
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