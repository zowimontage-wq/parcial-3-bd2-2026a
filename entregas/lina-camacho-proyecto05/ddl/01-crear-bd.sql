
DROP DATABASE IF EXISTS cine;
CREATE DATABASE cine CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cine;

CREATE TABLE genero (
  id_genero  INT AUTO_INCREMENT PRIMARY KEY,
  nombre     VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE pelicula (
  id_pelicula   INT AUTO_INCREMENT PRIMARY KEY,
  titulo        VARCHAR(150) NOT NULL,
  id_genero     INT NOT NULL,
  duracion_min  SMALLINT UNSIGNED NOT NULL,
  clasificacion VARCHAR(10) NOT NULL,
  sinopsis      TEXT,
  poster_url    VARCHAR(255),
  activa        BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_pelicula_genero FOREIGN KEY (id_genero) REFERENCES genero(id_genero),
  CONSTRAINT chk_duracion CHECK (duracion_min > 0),
  CONSTRAINT chk_clasificacion CHECK (clasificacion IN ('G','PG','PG-13','R','C','TP','12','15','18'))
) ENGINE=InnoDB;

CREATE TABLE sala (
  id_sala  INT AUTO_INCREMENT PRIMARY KEY,
  nombre   VARCHAR(50) NOT NULL UNIQUE,
  formato  VARCHAR(20) NOT NULL DEFAULT '2D'  
) ENGINE=InnoDB;

CREATE TABLE butaca (
  id_butaca INT AUTO_INCREMENT PRIMARY KEY,
  id_sala   INT NOT NULL,
  fila      CHAR(2) NOT NULL,
  numero    SMALLINT UNSIGNED NOT NULL,
  CONSTRAINT fk_butaca_sala FOREIGN KEY (id_sala) REFERENCES sala(id_sala) ON DELETE CASCADE,
  CONSTRAINT uq_butaca UNIQUE (id_sala, fila, numero)
) ENGINE=InnoDB;

CREATE TABLE funcion (
  id_funcion  INT AUTO_INCREMENT PRIMARY KEY,
  id_pelicula INT NOT NULL,
  id_sala     INT NOT NULL,
  fecha       DATE NOT NULL,
  hora        TIME NOT NULL,
  tarifa      DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_funcion_pelicula FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula),
  CONSTRAINT fk_funcion_sala     FOREIGN KEY (id_sala)     REFERENCES sala(id_sala),
  CONSTRAINT chk_tarifa CHECK (tarifa >= 0),
  CONSTRAINT uq_funcion_sala_horario UNIQUE (id_sala, fecha, hora)
) ENGINE=InnoDB;

CREATE TABLE cliente (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nombre     VARCHAR(120) NOT NULL,
  documento  VARCHAR(30) UNIQUE,
  email      VARCHAR(120),
  telefono   VARCHAR(30)
) ENGINE=InnoDB;

CREATE TABLE venta (
  id_venta    INT AUTO_INCREMENT PRIMARY KEY,
  fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_cliente  INT NULL,
  total       DECIMAL(10,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE boleto (
  id_boleto  INT AUTO_INCREMENT PRIMARY KEY,
  id_venta   INT NOT NULL,
  id_funcion INT NOT NULL,
  id_butaca  INT NOT NULL,
  precio     DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_boleto_venta   FOREIGN KEY (id_venta)   REFERENCES venta(id_venta) ON DELETE CASCADE,
  CONSTRAINT fk_boleto_funcion FOREIGN KEY (id_funcion) REFERENCES funcion(id_funcion),
  CONSTRAINT fk_boleto_butaca  FOREIGN KEY (id_butaca)  REFERENCES butaca(id_butaca),
  CONSTRAINT uq_boleto_funcion_butaca UNIQUE (id_funcion, id_butaca)
) ENGINE=InnoDB;

CREATE INDEX idx_funcion_fecha  ON funcion(fecha);
CREATE INDEX idx_boleto_funcion ON boleto(id_funcion);

DELIMITER //
CREATE TRIGGER trg_boleto_sala_valida
BEFORE INSERT ON boleto
FOR EACH ROW
BEGIN
  DECLARE v_sala_funcion INT;
  DECLARE v_sala_butaca  INT;
  SELECT id_sala INTO v_sala_funcion FROM funcion WHERE id_funcion = NEW.id_funcion;
  SELECT id_sala INTO v_sala_butaca  FROM butaca  WHERE id_butaca  = NEW.id_butaca;
  IF v_sala_funcion <> v_sala_butaca THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'La butaca no pertenece a la sala de la función';
  END IF;
END//
DELIMITER ;
