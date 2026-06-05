USE cine;
SET NAMES utf8mb4;

INSERT INTO genero (nombre) VALUES
  ('Acción'),          -- 1
  ('Comedia'),         -- 2
  ('Drama'),           -- 3
  ('Terror'),          -- 4
  ('Animación'),       -- 5
  ('Ciencia ficción'); -- 6

INSERT INTO pelicula (titulo, id_genero, duracion_min, clasificacion, sinopsis, activa) VALUES
  ('Dunas del Tiempo',         6, 155, 'PG-13', 'Un viaje épico a través de mundos desérticos.', TRUE),
  ('Risas en la Oficina',      2,  98, 'PG',    'Comedia sobre el caos de un lunes cualquiera.', TRUE),
  ('La Última Carta',          3, 120, 'PG-13', 'Un drama familiar contado a través de cartas.', TRUE),
  ('Sombras en la Niebla',     4, 105, 'R',     'Terror psicológico en un pueblo aislado.',      TRUE),
  ('El Reino Animado',         5,  92, 'G',     'Aventura animada para toda la familia.',        TRUE),
  ('Persecución Final',        1, 130, 'PG-13', 'Acción trepidante de principio a fin.',         TRUE),
  ('Corazón Valiente del Norte',3, 142,'PG-13', 'Épica histórica de honor y sacrificio.',        TRUE),
  ('Galaxia Perdida',          6, 118, 'PG',    'Una nave busca el camino de regreso a casa.',   TRUE);

INSERT INTO sala (nombre, formato) VALUES
  ('Sala 1', '2D'),   -- 1
  ('Sala 2', '3D'),   -- 2
  ('Sala 3', '2D');   -- 3

INSERT INTO butaca (id_sala, fila, numero)
SELECT s.id_sala, f.fila, n.numero
FROM sala s
CROSS JOIN (SELECT 'A' AS fila UNION SELECT 'B' UNION SELECT 'C' UNION SELECT 'D' UNION SELECT 'E') f
CROSS JOIN (SELECT 1 AS numero UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
            UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8) n;

INSERT INTO funcion (id_pelicula, id_sala, fecha, hora, tarifa) VALUES
  (1, 1, '2026-06-05', '14:00', 9000),   -- 1
  (2, 2, '2026-06-05', '16:00', 12000),  -- 2
  (3, 3, '2026-06-05', '18:00', 9000),   -- 3
  (4, 1, '2026-06-05', '20:00', 9000),   -- 4
  (5, 2, '2026-06-06', '14:00', 12000),  -- 5
  (6, 3, '2026-06-06', '16:00', 9000),   -- 6
  (1, 1, '2026-06-06', '18:30', 9000),   -- 7
  (7, 2, '2026-06-06', '21:00', 12000),  -- 8
  (8, 3, '2026-06-07', '15:00', 9000),   -- 9
  (2, 1, '2026-06-07', '17:00', 9000),   -- 10
  (6, 2, '2026-06-07', '19:00', 12000),  -- 11
  (4, 3, '2026-06-07', '22:00', 9000);   -- 12

INSERT INTO cliente (nombre, documento, email, telefono) VALUES
  ('María Gómez',     '1001', 'maria.gomez@correo.com',  '3001112233'),
  ('Juan Pérez',      '1002', 'juan.perez@correo.com',   '3002223344'),
  ('Laura Ríos',      '1003', 'laura.rios@correo.com',   '3003334455'),
  ('Carlos Méndez',   '1004', 'carlos.mendez@correo.com','3004445566'),
  ('Ana Torres',      '1005', 'ana.torres@correo.com',   '3005556677'),
  ('Diego Salas',     '1006', 'diego.salas@correo.com',  '3006667788'),
  ('Valentina Cruz',  '1007', 'valentina.cruz@correo.com','3007778899'),
  ('Andrés Rojas',    '1008', 'andres.rojas@correo.com', '3008889900');

INSERT INTO venta (fecha_venta, id_cliente, total) VALUES
  ('2026-06-05 13:30:00', 1, 0),   -- 1
  ('2026-06-05 15:40:00', 2, 0),   -- 2
  ('2026-06-05 17:45:00', 3, 0),   -- 3
  ('2026-06-05 19:50:00', 4, 0),   -- 4
  ('2026-06-06 13:30:00', 5, 0),   -- 5
  ('2026-06-06 15:30:00', 6, 0),   -- 6
  ('2026-06-06 18:00:00', NULL, 0),-- 7 
  ('2026-06-06 20:30:00', NULL, 0);-- 8 

INSERT INTO boleto (id_venta, id_funcion, id_butaca, precio)
SELECT f.rn, f.id_funcion, b.id_butaca, f.tarifa
FROM (
  SELECT id_funcion, id_sala, tarifa,
         ROW_NUMBER() OVER (ORDER BY id_funcion) AS rn
  FROM funcion
) f
JOIN (
  SELECT id_butaca, id_sala,
         ROW_NUMBER() OVER (PARTITION BY id_sala ORDER BY id_butaca) AS bn
  FROM butaca
) b ON b.id_sala = f.id_sala AND b.bn <= 5
WHERE f.rn <= 8;

UPDATE venta v
JOIN (SELECT id_venta, SUM(precio) AS total FROM boleto GROUP BY id_venta) t
  ON t.id_venta = v.id_venta
SET v.total = t.total;
