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
  ('TOY STORY 5',         6, 155, 'PG', 'Los juguetes están de regreso y esta vez, el propósito de jugar de Buzz Lightyear, Woody, Jessie y el resto del grupo se ve amenazado cuando se enfrentan a Lilypad, una nueva tableta que llega con sus propias ideas disruptivas sobre lo que es mejor para su niña, Bonnie. ¿Volverá el juego a ser como antes?', TRUE),
  ('SCARY MOVIE 6',      2,  94, 'R',    'Dos amigos se ven envueltos otra vez en el caos con asesinos, monstruos y criaturas sobrenaturales.', TRUE),
  ('AMOS DEL UNIVERSO',          3, 140, 'PG-13', 'He-Man, el hombre más poderoso del universo, va contra el malvado Skeletor para salvar el planeta Eternia y proteger los secretos del Castillo Grayskull.', TRUE),
  ('MICHAEL',     4, 127, 'PG-13',     'Michael es un retrato íntimo de la vida y el legado de uno de los artistas más influyentes que el mundo haya conocido. Protagonizada por Jaafar Jackson en su debut cinematográfico, quien muestra la historia de la vida de Michael Jackson desde el descubrimiento de su extraordinario talento como líder de los Jackson Five hasta convertirse en el innegable artista visionario cuya ambición creativa impulsó una búsqueda incansable para ser el artista más grande del mundo.',      TRUE),
  ('El Afinador',         5,  109, 'R',     'Henry (Dustin Hoffman) es un veterano afinador de pianos que está perdiendo la audición. A su lado trabaja Niki (Leo Woodall), un joven aprendiz tímido y retraído, antiguo niño prodigio del piano que padece hiperacusia, una rara condición que le provoca percibir los sonidos a un volumen exageradamente alto, juntos forman la mejor pareja de afinadores de pianos de la ciudad. La condición de Niki, lejos de ser solo una carga, encierra una inesperada ventaja: una gran habilidad para abrir cajas fuertes, lo que pone su vida patas arriba.',        TRUE),
  ('Backrooms',        1, 105, '15', '
Una extraña puerta aparece en el sótano de una sala de exposición de muebles.',         TRUE),
  ('El Diablo Viste a la Moda 2',3, 119,'PG-13', 'Casi veinte años después de dar vida a los icónicos personajes Miranda, Andy, Emily y Nigel; Meryl Streep, Anne Hathaway, Emily Blunt y Stanley Tucci regresan a las elegantes calles de Nueva York y a las sofisticadas oficinas de la revista Runway en la esperada secuela del fenómeno de 2006 que marcó a toda una generación.',        TRUE),
  ('El Día de la Revelación',          6, 145, 'PG-13',    'Un evento global sin precedentes ocurre cuando se confirma oficialmente la presencia de inteligencia no humana en la Tierra, desencadenando una serie de encuentros cercanos que cambian el rumbo de la humanidad.',   TRUE);

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
