-- ============================================================
--  Confitería (módulo extra) — catálogo de combos personalizables
--  Modelo en 3FN: producto_confiteria 1—N grupo_opcion 1—N opcion.
--  El carrito NO se persiste: vive en la sesión de Flask.
-- ============================================================
USE cine;

CREATE TABLE producto_confiteria (
  id_producto     INT AUTO_INCREMENT PRIMARY KEY,
  nombre          VARCHAR(80)  NOT NULL,
  descripcion     VARCHAR(200) NOT NULL DEFAULT '',   -- "Incluye: 1 Crispeta Pequeña + 1 Gaseosa 22 oz"
  imagen_url      VARCHAR(300) NOT NULL DEFAULT '',
  precio_normal   DECIMAL(10,2) NOT NULL,             -- otros medios de pago
  precio_cineplus DECIMAL(10,2) NOT NULL,             -- pagando con CINE+
  activo          BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT chk_precio_conf CHECK (precio_normal >= 0 AND precio_cineplus >= 0)
) ENGINE=InnoDB;

CREATE TABLE grupo_opcion (
  id_grupo    INT AUTO_INCREMENT PRIMARY KEY,
  id_producto INT NOT NULL,
  nombre      VARCHAR(60) NOT NULL,                   -- "CRISPETA PEQUEÑA", "BEBIDA"
  orden       INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_grupo_producto FOREIGN KEY (id_producto)
      REFERENCES producto_confiteria(id_producto) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE opcion (
  id_opcion    INT AUTO_INCREMENT PRIMARY KEY,
  id_grupo     INT NOT NULL,
  nombre       VARCHAR(60) NOT NULL,                  -- "Sal Mantequilla", "Gaseosa 22 oz"
  delta_precio DECIMAL(10,2) NOT NULL DEFAULT 0,      -- las opciones con (*) modifican el precio
  por_defecto  BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT fk_opcion_grupo FOREIGN KEY (id_grupo)
      REFERENCES grupo_opcion(id_grupo) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_grupo_producto ON grupo_opcion(id_producto);
CREATE INDEX idx_opcion_grupo   ON opcion(id_grupo);

-- ------------------------------------------------------------
--  Datos de prueba
-- ------------------------------------------------------------
INSERT INTO producto_confiteria (nombre, descripcion, imagen_url, precio_normal, precio_cineplus) VALUES
  ('Combo 1', 'Incluye: 1 Crispeta Pequeña + 1 Gaseosa 22 oz', 'https://placehold.co/600x400/2b1d1d/ffffff?text=COMBO+1', 19500, 16000),
  ('Combo 2', 'Incluye: 1 Crispeta Pequeña + 1 Gaseosa 22 oz + 1 Perro', 'https://placehold.co/600x400/2b1d1d/ffffff?text=COMBO+2', 26500, 22000),
  ('Combo 3', 'Incluye: 1 Crispeta Mediana + 1 Gaseosa 32 oz', 'https://placehold.co/600x400/2b1d1d/ffffff?text=COMBO+3', 28000, 23500),
  ('Combo 4', 'Incluye: 1 Crispeta Mediana + 1 Gaseosa 32 oz + 1 Perro', 'https://placehold.co/600x400/2b1d1d/ffffff?text=COMBO+4', 33000, 27500),
  ('Combo 5', 'Incluye: 2 Crispetas Pequeñas + 2 Gaseosas 22 oz', 'https://placehold.co/600x400/2b1d1d/ffffff?text=COMBO+5', 36000, 30000),
  ('Combo Película', 'Incluye: 1 Crispeta Grande + 2 Gaseosas 32 oz', 'https://placehold.co/600x400/2b1d1d/ffffff?text=COMBO+PELICULA', 42000, 35000),
  ('Combo Salchipeta', 'Incluye: 1 Crispeta Pequeña + 1 Gaseosa 22 oz + 1 Salchipapa', 'https://placehold.co/600x400/2b1d1d/ffffff?text=SALCHIPETA', 31000, 26000),
  ('Gafas 3D', 'Gafas 3D reutilizables para funciones en formato 3D', 'https://placehold.co/600x400/7a0d0d/ffffff?text=GAFAS+3D', 9500, 7500);

-- Combo 1: crispeta + bebida personalizables
INSERT INTO grupo_opcion (id_producto, nombre, orden) VALUES
  (1, 'CRISPETA PEQUEÑA', 1),
  (1, 'BEBIDA', 2);
INSERT INTO opcion (id_grupo, nombre, delta_precio, por_defecto) VALUES
  (1, 'Sal Mantequilla', 0, TRUE),
  (1, 'Sal', 0, FALSE),
  (1, 'Caramelo', 1500, FALSE),
  (2, 'Gaseosa 22 oz', 0, TRUE),
  (2, 'Gaseosa 32 oz', 2000, FALSE),
  (2, 'Agua 600 ml', 0, FALSE);

-- Combo 2: crispeta + bebida
INSERT INTO grupo_opcion (id_producto, nombre, orden) VALUES
  (2, 'CRISPETA PEQUEÑA', 1),
  (2, 'BEBIDA', 2);
INSERT INTO opcion (id_grupo, nombre, delta_precio, por_defecto) VALUES
  (3, 'Sal Mantequilla', 0, TRUE),
  (3, 'Caramelo', 1500, FALSE),
  (4, 'Gaseosa 22 oz', 0, TRUE),
  (4, 'Gaseosa 32 oz', 2000, FALSE),
  (4, 'Agua 600 ml', 0, FALSE);

-- Combo 3: bebida
INSERT INTO grupo_opcion (id_producto, nombre, orden) VALUES
  (3, 'BEBIDA', 1);
INSERT INTO opcion (id_grupo, nombre, delta_precio, por_defecto) VALUES
  (5, 'Gaseosa 32 oz', 0, TRUE),
  (5, 'Gaseosa 22 oz', -1500, FALSE),
  (5, 'Agua 600 ml', -1500, FALSE);

-- Combo Película: bebida doble
INSERT INTO grupo_opcion (id_producto, nombre, orden) VALUES
  (6, 'CRISPETA GRANDE', 1),
  (6, 'BEBIDA', 2);
INSERT INTO opcion (id_grupo, nombre, delta_precio, por_defecto) VALUES
  (7, 'Sal Mantequilla', 0, TRUE),
  (7, 'Mixta (sal + caramelo)', 2000, FALSE),
  (8, '2 Gaseosas 32 oz', 0, TRUE),
  (8, '2 Gaseosas 22 oz', -2500, FALSE);
