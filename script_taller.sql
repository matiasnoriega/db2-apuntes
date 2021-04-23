/*DROP TABLE IF EXISTS viernes;
CREATE TABLE viernes(
		fecha_hora	timestamp without time zone NOT NULL,
		id			integer						NOT NULL,
		tipo		varchar						NOT NULL,
		"X"			smallint					NOT NULL,
		"Y"			smallint					NOT NULL);

COPY viernes
FROM '/home/matias/viernes.csv'
DELIMITER AS ','
CSV HEADER;

COPY viernes
FROM '/home/matias/viernes2.csv'
DELIMITER AS ','
CSV HEADER;

DROP TABLE IF EXISTS sabado;
CREATE TABLE sabado(
		fecha_hora	timestamp without time zone NOT NULL,
		id			integer						NOT NULL,
		tipo		varchar						NOT NULL,
		"X"			smallint					NOT NULL,
		"Y"			smallint					NOT NULL);


COPY sabado
FROM '/home/matias/sabado.csv'
DELIMITER AS ','
CSV HEADER;

DROP TABLE IF EXISTS domingo;
CREATE TABLE domingo(
		fecha_hora	timestamp without time zone NOT NULL,
		id			integer						NOT NULL,
		tipo		varchar						NOT NULL,
		"X"			smallint					NOT NULL,
		"Y"			smallint					NOT NULL);


COPY domingo
FROM '/home/matias/domingo.csv'
DELIMITER AS ','
CSV HEADER;


DROP TABLE IF EXISTS optimizacion.los_tres_dias;

CREATE TABLE optimizacion.los_tres_dias as (
	SELECT 	*
	FROM	optimizacion.viernes
	
	UNION ALL
	SELECT 	*
	FROM	optimizacion.sabado
	
	UNION ALL
	SELECT 	*
	FROM	optimizacion.domingo
);
*/

--a) ¿ Cuantas filas tiene la tabla del dia viernes?
SELECT 	COUNT(*)
FROM 	optimizacion.viernes; --6010914 || Successfully run. Total query runtime: 165 msec.
--b) ¿ Cuantos check-in se registraron el dia viernes?
SELECT COUNT(*)
FROM 	optimizacion.viernes
WHERE 	tipo = 'check-in'; --82462 || Successfully run. Total query runtime: 209 msec. 1 rows affected.
--c) ¿ Cuantos movement se registraron el dia viernes?
SELECT COUNT(*)
FROM 	optimizacion.viernes
WHERE 	tipo like 'movement'; --5928452 || Successfully run. Total query runtime: 242 msec. 1 rows affected.
--d) ¿ Cuantos visitantes tuvo el parque en los tres d´ıas?
SELECT COUNT(DISTINCT id)
FROM 	optimizacion.los_tres_dias; -- 11374 || Successfully run. Total query runtime: 7 secs 423 msec. || 1 rows affected.
--e) ¿ Cuantos check-in se registraron en los tres d´ıas?
SELECT COUNT(*)
FROM 	optimizacion.los_tres_dias
WHERE 	tipo like 'check-in'; -- 328838 || Successfully run. Total query runtime: 733 msec. 1 rows affected.
--f) ¿ Cuantos movement se registraron en los tres d´ıas?
SELECT COUNT(*)
FROM 	optimizacion.los_tres_dias
WHERE 	tipo like 'movement'; -- 25693123 || Successfully run. Total query runtime: 963 msec. 1 rows affected.

-- 6. (Optimizaci´on de consultas con y sin ´ındices) A continuaci´on, resuelva la siguiente consulta con dos script distintos y analicaremos c´omo, en forma independiente al dise˜no f´ısico,
-- podemoos reducir el tiempo de ejecuci´on desde varias horas a pocos segundos.
-- Obtener para cada id, cu´antos check-in y cu´antos movimientos tuvo en los tres dias. Formato
-- de salida: (id, cant-chek-in, cant-mov). Proponga varias soluciones.
-- Analizaremos los siguientes 4 tipos de diseño:

-- CONSULTA M - Primera aproximación
SELECT 	id,
	count(*) FILTER (WHERE tipo = 'check-in') as "cant-check-in",
	count(*) FILTER (WHERE tipo = 'movement') as "cant-move"
FROM optimizacion.los_tres_dias
GROUP BY id;

-- CONSULTA P - Aproximación del Profesor
SELECT 	t1.id, t1.cant_check_in, t2.cant_movement
FROM 	(SELECT id, count(*) as cant_check_in
		FROM optimizacion.los_tres_dias
	 	WHERE tipo = 'check-in'
	 	GROUP BY id) t1,
		(SELECT id, count(*) as cant_movement
		FROM optimizacion.los_tres_dias
		WHERE tipo = 'movement'
		GROUP BY id) t2
WHERE t1.id = t2.id;

/* a) Sin índices
- Con '=' 
CONSULTA M: Successfully run. Total query runtime: 1 secs 768 msec. 11374 rows affected.
CONSULTA P: Successfully run. Total query runtime: 2 secs 336 msec. 11374 rows affected.
- Con LIKE
CONSULTA M: Successfully run. Total query runtime: 1 secs 951 msec. 11374 rows affected.
CONSULTA P: Successfully run. Total query runtime: 2 secs 459 msec. 11374 rows affected.
--b) Con un ´unico ´ındice
- Con '=' 
CONSULTA M: Successfully run. Total query runtime: 1 secs 742 msec. 11374 rows affected.
CONSULTA P: Successfully run. Total query runtime: 1 secs 959 msec. 11374 rows affected.
- Con LIKE
CONSULTA M: Successfully run. Total query runtime: 1 secs 943 msec. 11374 rows affected.
CONSULTA P: Successfully run. Total query runtime: 2 secs 476 msec. 11374 rows affected.
--c) Con dos ´ındices
- Con '='
CONSULTA M: Successfully run. Total query runtime: 1 secs 760 msec. 11374 rows affected.
CONSULTA P: Successfully run. Total query runtime: 1 secs 921 msec. 11374 rows affected.
- Con LIKE
CONSULTA M: Successfully run. Total query runtime: 1 secs 927 msec. 11374 rows affected.
CONSULTA P: Successfully run. Total query runtime: 2 secs 458 msec. 11374 rows affected.
--d) Con tres ´ındices
- Con '='
CONSULTA M: Successfully run. Total query runtime: 1 secs 739 msec. 11374 rows affected.
CONSULTA P: Successfully run. Total query runtime: 1 secs 920 msec. 11374 rows affected.
- Con LIKE
CONSULTA M: Successfully run. Total query runtime: 1 secs 930 msec. 11374 rows affected.
CONSULTA P: Successfully run. Total query runtime: 2 secs 455 msec. 11374 rows affected.

7. Idem al punto anterior, con la consulta:
- Obtener cu´ales son las coordenadas de entrada al parque. (ayuda: use solamente la tabla
de los d´ıas viernes).
*/
SELECT "X", "Y"
FROM optimizacion.viernes;
select count(*) from optimizacion.viernes;
SELECT EXTRACT(DAY FROM fecha_hora) as day FROM optimizacion.los_tres_dias group by day;

DROP INDEX IF EXISTS optimizacion.index_tipo;
DROP INDEX IF EXISTS optimizacion.index_id;
DROP INDEX IF EXISTS optimizacion.index_viernes;
CREATE INDEX index_tipo ON optimizacion.los_tres_dias(tipo) WHERE tipo = 'check-in'; --CREATE INDEX Query returned successfully in 1 secs 586 msec.
CREATE INDEX index_viernes ON optimizacion.los_tres_dias(fecha_hora) WHERE EXTRACT(DAY FROM fecha_hora) = 6; --CREATE INDEX Query returned successfully in 14 secs 167 msec.
CREATE INDEX index_id ON optimizacion.los_tres_dias(id); -- CREATE INDEX Query returned successfully in 10 secs 787 msec.

--8. (Análisis de consultas) Para cada una de las siguientes consultas, exprese en lenguaje coloquial qu´e es lo que hacen, y mida el tiempo de ejecuci´on de las mismas sin utilizar ´ındices: 

-- Selecciona de la tabla SABADO todos los campos de las entradas cuyo visitante no haya visitado el parque el Viernes
/*
SELECT s.*
FROM optimizacion.sabado s
WHERE NOT EXISTS ( 	SELECT '1'
					FROM optimizacion.viernes v
					WHERE s.id = v.id);
					
Successfully run. Total query runtime: 5 secs 189 msec. 5918355 rows affected.
*/

--
/*
SELECT s.*
FROM optimizacion.sabado s
WHERE s.id NOT IN(	SELECT DISTINCT v.id
					FROM optimizacion.viernes v
					WHERE s.id = v.id);
					
*/

/*
SELECT s.*
FROM optimizacion.sabado s
WHERE s.id NOT IN (	SELECT v.id
					FROM optimizacion.viernes v);
*/
-- Los dos queries anteriores en el EXPLAIN arrojan una sección llamada "SUBPLAN 1" en rojo
/*
SELECT s.*
FROM optimizacion.sabado s
LEFT JOIN optimizacion.viernes v
ON s.id = v.id
WHERE v.id IS NULL;
*/

-- Successfully run. Total query runtime: 5 secs 176 msec. 5918355 rows affected.


