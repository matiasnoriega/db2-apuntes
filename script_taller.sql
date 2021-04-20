DROP TABLE IF EXISTS viernes;
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

DROP INDEX IF EXISTS optimizacion.index_tipo;
CREATE INDEX index_tipo ON optimizacion.los_tres_dias(tipo) WHERE tipo = 'check-in';
--CREATE INDEX Query returned successfully in 1 secs 586 msec.


--a) ¿ Cuantas filas tiene la tabla del dia viernes?
SELECT 	COUNT(*)
FROM 	optimizacion.viernes; --6010914 || Successfully run. Total query runtime: 165 msec.
--b) ¿ Cuantos check-in se registraron el dia viernes?
SELECT COUNT(*)
FROM 	optimizacion.viernes
WHERE 	tipo = 'check-in'; --82462
--c) ¿ Cuantos movement se registraron el dia viernes?
SELECT COUNT(*)
FROM 	optimizacion.viernes
WHERE 	tipo like 'movement'; --5928452
--d) ¿ Cuantos visitantes tuvo el parque en los tres d´ıas?
SELECT COUNT(DISTINCT id)
FROM 	optimizacion.los_tres_dias; -- 11374 || Successfully run. Total query runtime: 7 secs 423 msec. || 1 rows affected.
--e) ¿ Cuantos check-in se registraron en los tres d´ıas?
SELECT COUNT(*)
FROM 	optimizacion.los_tres_dias
WHERE 	tipo like 'check-in'; -- 328838
--f) ¿ Cuantos movement se registraron en los tres d´ıas?
SELECT COUNT(*)
FROM 	optimizacion.los_tres_dias
WHERE 	tipo like 'movement'; -- 25693123

-- 6. (Optimizaci´on de consultas con y sin ´ındices) A continuaci´on, resuelva la siguiente consulta con dos script distintos y analicaremos c´omo, en forma independiente al dise˜no f´ısico,
-- podemoos reducir el tiempo de ejecuci´on desde varias horas a pocos segundos.
-- Obtener para cada id, cu´antos check-in y cu´antos movimientos tuvo en los tres dias. Formato
-- de salida: (id, cant-chek-in, cant-mov). Proponga varias soluciones.
-- Analizaremos los siguientes 4 tipos de diseño:

-- Primera aproximación
SELECT 	id,
	count(*) FILTER (WHERE tipo LIKE 'check-in') as "cant-check-in",
	count(*) FILTER (WHERE tipo = 'movement') as "cant-move"
FROM optimizacion.los_tres_dias
GROUP BY id;
-- Successfully run. Total query runtime: 1 secs 974 msec. 11374 rows affected. || usando LIKE (sin index)
-- Successfully run. Total query runtime: 1 secs 819 msec. 11374 rows affected. || usando = (sin index)
-- Successfully run. Total query runtime: 1 secs 844 msec. 11374 rows affected. || usando LIKE (con index)
-- Successfully run. Total query runtime: 1 secs 844 msec. 11374 rows affected. || usando = (con index)
--a) Sin ´ındices
--b) Con un ´unico ´ındice
--c) Con dos ´ındices
--d) Con tres ´ındices

