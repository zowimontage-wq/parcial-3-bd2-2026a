USE cine;
SET NAMES utf8mb4;

INSERT INTO genero (nombre) VALUES
  ('Acción'),          -- 1
  ('Comedia'),         -- 2
  ('Drama'),           -- 3
  ('Terror'),          -- 4
  ('Animación'),       -- 5
  ('Ciencia ficción'), -- 6
  ('Aventura'),        -- 7
  ('Suspenso'),        -- 8
  ('Misterio'),        -- 9
  ('Historia'),        -- 10
  ('Biografía'),       -- 11
  ('Romance'),         -- 12
  ('Fantasía');        -- 13

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
  -- ===== SALA 1 (2D) - 06-08 =====
  (5, 1, '2026-06-08', '12:00', 9000),   -- El Reino Animado
  (5, 1, '2026-06-08', '14:30', 9000),   -- El Reino Animado
  (1, 1, '2026-06-08', '17:30', 9000),   -- Dunas del Tiempo
  (1, 1, '2026-06-08', '20:30', 9000),   -- Dunas del Tiempo

  -- ===== SALA 2 (3D) - 06-08 =====
  (6, 2, '2026-06-08', '12:30', 12000),  -- Persecución Final
  (6, 2, '2026-06-08', '15:30', 12000),  -- Persecución Final
  (2, 2, '2026-06-08', '18:00', 12000),  -- Risas en la Oficina
  (2, 2, '2026-06-08', '20:30', 12000),  -- Risas en la Oficina

  -- ===== SALA 3 (2D) - 06-08 =====
  (4, 3, '2026-06-08', '13:00', 9000),   -- Sombras en la Niebla
  (4, 3, '2026-06-08', '15:45', 9000),   -- Sombras en la Niebla
  (3, 3, '2026-06-08', '18:30', 9000),   -- La Última Carta
  (3, 3, '2026-06-08', '21:00', 9000),   -- La Última Carta

  -- ===== SALA 1 (2D) - 06-09 =====
  (5, 1, '2026-06-09', '12:00', 9000),
  (5, 1, '2026-06-09', '14:30', 9000),
  (7, 1, '2026-06-09', '17:30', 9000),   -- Corazón Valiente del Norte
  (7, 1, '2026-06-09', '21:00', 9000),   -- Corazón Valiente del Norte

  -- ===== SALA 2 (3D) - 06-09 =====
  (8, 2, '2026-06-09', '12:30', 12000),  -- Galaxia Perdida
  (8, 2, '2026-06-09', '15:00', 12000),  -- Galaxia Perdida
  (6, 2, '2026-06-09', '17:30', 12000),  -- Persecución Final
  (6, 2, '2026-06-09', '20:00', 12000),  -- Persecución Final

  -- ===== SALA 3 (2D) - 06-09 =====
  (4, 3, '2026-06-09', '13:00', 9000),   -- Sombras en la Niebla
  (4, 3, '2026-06-09', '15:45', 9000),   -- Sombras en la Niebla
  (2, 3, '2026-06-09', '18:00', 9000),   -- Risas en la Oficina
  (2, 3, '2026-06-09', '20:30', 9000),   -- Risas en la Oficina

  -- ===== SALA 1 (2D) - 06-10 =====
  (1, 1, '2026-06-10', '12:00', 9000),   -- Dunas del Tiempo
  (1, 1, '2026-06-10', '15:00', 9000),   -- Dunas del Tiempo
  (5, 1, '2026-06-10', '18:30', 9000),   -- El Reino Animado
  (5, 1, '2026-06-10', '20:30', 9000),   -- El Reino Animado

  -- ===== SALA 2 (3D) - 06-10 =====
  (8, 2, '2026-06-10', '12:30', 12000),  -- Galaxia Perdida
  (8, 2, '2026-06-10', '15:00', 12000),  -- Galaxia Perdida
  (6, 2, '2026-06-10', '17:30', 12000),  -- Persecución Final
  (6, 2, '2026-06-10', '20:00', 12000),  -- Persecución Final

  -- ===== SALA 3 (2D) - 06-10 =====
  (3, 3, '2026-06-10', '13:00', 9000),   -- La Última Carta
  (3, 3, '2026-06-10', '15:30', 9000),   -- La Última Carta
  (7, 3, '2026-06-10', '18:30', 9000),   -- Corazón Valiente del Norte
  (7, 3, '2026-06-10', '21:30', 9000);   -- Corazón Valiente del Norte

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
  ('2026-06-08 13:30:00', 1, 0),
  ('2026-06-08 15:40:00', 2, 0),
  ('2026-06-08 17:45:00', 3, 0),
  ('2026-06-08 19:50:00', 4, 0),
  ('2026-06-09 13:30:00', 5, 0),
  ('2026-06-09 15:30:00', 6, 0),
  ('2026-06-09 18:00:00', NULL, 0),
  ('2026-06-09 20:30:00', NULL, 0);

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
