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