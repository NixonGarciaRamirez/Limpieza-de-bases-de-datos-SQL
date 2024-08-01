CREATE DATABASE IF NOT exists clean;

CREATE schema `intento`;

-- VISUALIZACION
USE clean;

DELIMITER //
CREATE PROCEDURE view2()
BEGIN 
	SELECT * FROM limpieza ;
END //
DELIMITER ; 

CALL x();
-- ###################################################################################################################
-- RENOMBRAR COLUMNAS
-- ###################################################################################################################
ALTER TABLE limpieza CHANGE COLUMN  `ï»¿Id?empleado` Id_Empleado varchar(20) null;
ALTER TABLE limpieza CHANGE COLUMN `gÃ©nero` Gender varchar(20) null;
ALTER TABLE limpieza CHANGE COLUMN Apellido Last_name VARCHAR(50) null;
ALTER TABLE limpieza CHANGE COLUMN star_date start_date VARCHAR(50) null;

-- ###################################################################################################################
-- IDENTIFICACION DE DATOS DUPLICADOS
-- ###################################################################################################################
SELECT Id_Empleado , COUNT(*) as Duplicados
FROM limpieza
GROUP BY Id_Empleado
HAVING Duplicados > 1;

-- CONTAR DUPLICADOS

SELECT COUNT(*) AS Duplicados
FROM (
SELECT Id_Empleado , COUNT(*) as Duplicados
FROM limpieza
GROUP BY Id_Empleado
HAVING Duplicados > 1
) as a;

-- ELIMINAR DUPLICADOS
RENAME TABLE limpieza TO conduplicados; -- primero renombramos la tabla

CREATE TEMPORARY TABLE temp_limpieza AS -- ahora creamos una tabla temporal sin datos duplicados 
SELECT DISTINCT * FROM conduplicados; -- y recuerda distinct solo cuenta los datos unicos 

SELECT count(*) AS original FROM temp_limpieza; -- vizualizamos si solo extrajo los valores unicos, en este caso deberia restar 9

CREATE TABLE limpieza AS SELECT * FROM temp_limpieza; -- guardamos los datos no duplicados dentro de una nueva tabla

CALL view() ;


-- ###################################################################################################################
-- VER PROPIEDADES DE LOS DATOS
-- ###################################################################################################################

USE clean;
DESCRIBE limpieza;

-- ###################################################################################################################
-- REMOVER ESPACIOS EXTRAS
-- ###################################################################################################################

USE clean;
CALL view2();

-- identificamos las filas que tengan espacios
SELECT Name FROM limpieza
WHERE  length(Name) - LENGTH(trim(Name)) > 0;-- trim es uan funcion que se encarga de quitar los caracteres especialies como espacios

-- modificacion de la tabla
SELECT Name , trim(Name) as name
FROM  limpieza
WHERE  length(Name) - LENGTH(trim(Name)) > 0;

USE clean;

SET sql_safe_updates = 0; -- recuerda que por defecto el modo seuro siempre esta activado, para modificar datos debemos desactivarlo

UPDATE `limpieza` SET `Name` = trim(Name) WHERE  length(Name) - LENGTH(trim(Name)) > 0; -- Nombre 
UPDATE `limpieza` SET `Last_name` = trim(Last_name) WHERE  length(Last_name) - LENGTH(trim(Last_name)) > 0; -- Apellidos


-- ###################################################################################################################
-- REMOVER ESPACIOS EXTRAS ENTRE PALABRAS
-- ###################################################################################################################


-- En este caso modificaremos un poco la columna area con fines demostrativos
UPDATE limpieza SET area = REPLACE(area , ' ', '       '); -- aqui agregamos mas espacio entre textos

-- identificamos los esapcios vacios 
SELECT area FROM limpieza
WHERE area regexp '\\s{2,}'; -- \\s: Representa un espacio en blanco

-- probamos la funcion
SELECT area, trim(regexp_replace(area , '\\s{2,}' , ' ' )) AS ensayo FROM limpieza;

-- actualizamos la tabla
UPDATE limpieza SET area = trim(regexp_replace(area , '\\s{2,}' , ' ' ));

-- ###################################################################################################################
-- CAMBIAR EL IDIOMA DE LOS DATOS DE LA COLUMNA DE GENERO (ESP - ENG)
-- ###################################################################################################################

-- visualizacion del primer cambio
SELECT Gender,
CASE 
	WHEN Gender = 'hombre' THEN 'male'
    WHEN Gender = 'mujer' THEN 'female'
    ELSE 'other'
END as gender1
FROM limpieza;

-- actializacion de datos
UPDATE limpieza SET Gender = CASE 
	WHEN Gender = 'hombre' THEN 'male'
    WHEN Gender = 'mujer' THEN 'female'
    ELSE 'other'
END;

call view2();
-- ###################################################################################################################
-- CAMBIAR LOS VALORES BOLEANOS DE TYPE
-- 0 = hibrido ; 1 = remoto
-- ###################################################################################################################


-- revisamos el tipo de datos que tiene la columna type , en este caso es INT y lo vaos a camciar por un tipo texto
DESCRIBE limpieza;

ALTER TABLE limpieza MODIFY COLUMN type TEXT; -- cambiamos el tipo de dato de la columna

-- realizamos el ensaño  del query
SELECT type,
CASE
	WHEN type = 1 then 'Remote'
    WHEN type = 0 then 'Hybrid'
    ELSE 'others'
END as ejemplo
FROM limpieza;

-- Actualziacion de  la informacion
UPDATE limpieza
SET TYPE = CASE
	WHEN type = 1 then 'Remote'
    WHEN type = 0 then 'Hybrid'
    ELSE 'others'
END;

CALL view2;

-- ###################################################################################################################
-- AJUSTE DE FORMATOS DE TEXTOS
-- ###################################################################################################################

-- Probamos la funcion
SELECT salary,  
CAST(TRIM(REPLACE(REPLACE(salary, '$', ''), ',','' )) AS DECIMAL (15,2) ) from limpieza AS salary1;

-- Actualizamos los datos
UPDATE limpieza SET salary = CAST(TRIM(REPLACE(REPLACE(salary, '$', ''), ',','' )) AS DECIMAL (15,2) );

-- Modificar el tipo de dato de texto a numero
ALTER TABLE limpieza MODIFY COLUMN salary float null;
CALL view2;
DESCRIBE limpieza;


-- ###################################################################################################################
-- AJUSTAR FORMATO DE FECHAS
-- ###################################################################################################################

-- de M/D/A  a A/M/D
SELECT birth_date FROM limpieza;

-- organizacion de la fecha para birth_date
SELECT birth_date, CASE 
	WHEN birth_date LIKE '%/%' THEN date_format(str_to_date(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birth_date LIKE '%-%' THEN date_format(str_to_date(birth_date, '%m-%d-%Y'), '%Y-%m-%d')
ELSE null
END AS new_birthdate
FROM limpieza;

UPDATE limpieza SET birth_date = CASE 
	WHEN birth_date LIKE '%/%' THEN date_format(str_to_date(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birth_date LIKE '%-%' THEN date_format(str_to_date(birth_date, '%m-%d-%Y'), '%Y-%m-%d')
ELSE null
END;

CALL view2;

-- Modificar la propiedad que pase de texto a fecha
ALTER TABLE limpieza MODIFY COLUMN birth_date date;
DESCRIBE limpieza;


-- organizacion de la fecha para start_date
SELECT start_date, CASE 
	WHEN start_date LIKE '%/%' THEN date_format(str_to_date(start_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN start_date LIKE '%-%' THEN date_format(str_to_date(start_date, '%m-%d-%Y'), '%Y-%m-%d')
ELSE null
END AS new_birthdate
FROM limpieza;

UPDATE limpieza SET start_date = CASE 
	WHEN start_date LIKE '%/%' THEN date_format(str_to_date(start_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN start_date LIKE '%-%' THEN date_format(str_to_date(start_date, '%m-%d-%Y'), '%Y-%m-%d')
ELSE null
END;

USE clean;
CALL view2;

-- Modificar la propiedad que pase de texto a fecha
ALTER TABLE limpieza MODIFY COLUMN start_date date;
DESCRIBE limpieza;


-- ###################################################################################################################
-- PROPIEDADES EXTRAS DE LAS FECHAS
-- ###################################################################################################################

-- # "ensayos" hacer consultas de como quedarían los datos si queremos ensayar diversos cambios.
SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s') AS fecha FROM limpieza;  -- convierte el valor en objeto de fecha (timestamp)
SELECT finish_date, date_format(str_to_date(finish_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') AS fecha FROM limpieza; -- objeto en formato de fecha, luego da formato en el deseado '%Y-%m-%d %H:' o sea quitamos el UTC y la hora dejando solo la fecha con guiones
SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d') AS fd FROM limpieza; -- separar solo la fecha

-- aqui la idea es ver cual es la principal utilidad de date_format contra el str_to_date
SELECT  finish_date, str_to_date(finish_date, '%H:%i:%s') AS hour_stamp FROM limpieza; -- separar solo la hora no funciona
SELECT  finish_date, date_format(finish_date, '%H:%i:%s') AS hour_stamp FROM limpieza; -- separar solo la hora(marca de tiempo)

-- # Diviendo los elementos de la hora
SELECT finish_date,
    date_format(finish_date, '%H') AS hora,
    date_format(finish_date, '%i') AS minutos,
    date_format(finish_date, '%s') AS segundos,
    date_format(finish_date, '%H:%i:%s') AS hour_stamp
FROM limpieza;

/* Diferencia entre timestamp y datatime
-- timestamp (YYYY - MM - DD HH:MM:SS) - edsde: 01 enero 1970 a las 00:00:00 UTC , hasta milecimas de segundo
-- datatime desde el año 1000 a 9999 -no tiene en cuenta la zona horaria , hasta segunfos . */

-- creacion de una copia de seguridad para finish_date
ALTER TABLE limpieza ADD COLUMN date_bachup text;
SET sql_safe_updates = 0;
UPDATE limpieza SET date_bachup = finish_date ;

-- aqui covertimus la columna finish date
UPDATE limpieza SET finish_date = str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC') 
WHERE finish_date <>'' ; -- <> significa diferente
CALL view2;

-- ahora vamos a separar en dos columnas una de fecha y otra de hora
ALTER TABLE limpieza 
	ADD COLUMN fecha date, 
	ADD COLUMN hora time;
    
UPDATE limpieza SET fecha = date(finish_date), hora = time(finish_date)  
WHERE finish_date is not null and finish_date <> '';

-- ahora los espacios en blanco los dejaremos como nulos
UPDATE limpieza SET finish_date = null WHERE finish_date = '';


-- ahora establecemos el tipo de datyo correcto de la tabla
ALTER TABLE limpieza MODIFY COLUMN finish_date datetime;
DESCRIBE limpieza;
CALL view2;

-- ###################################################################################################################
-- CALCULOS CON FECHAS
-- ###################################################################################################################

-- calculemos la edad de los empleados
ALTER TABLE limpieza ADD COLUMN age INT;

-- timestampdiff calcula la diferencia entre 2 fechas distintas 
UPDATE limpieza SET age = timestampdiff(year, birth_date , curdate()); -- curdate nos da la fecha actual abajo hay otra difeencias que podemos aplicar

/* Calcular diferencias
SECOND: Diferencia en segundos.
MINUTE: Diferencia en minutos.
HOUR: Diferencia en horas.
DAY: Diferencia en días.
WEEK: Diferencia en semanas.
MONTH: Diferencia en meses.
QUARTER: Diferencia en trimestres.
DAY_HOUR: Diferencia en días y horas.
YEAR_MONTH: Diferencia en años y meses. */

call view2;

-- ###################################################################################################################
-- FUNCIONES DE TEXTO
-- ###################################################################################################################

-- Se creara un coreo para el empleado el cual se componga del primer nombre del empleado, una raya al piso, despues las 2 primeras letras del apellido, segido del @ con el dominio de la empresa
 
 SELECT concat(substring_index(Name, ' ', 1 ) , '_' , substring(Last_name , 1 , 2) , '.' , substring(type , 1 , 1) , '@usb.com' ) AS email
 FROM limpieza;
 
 ALTER TABLE limpieza ADD COLUMN email varchar(100);
 UPDATE limpieza SET email = concat(substring_index(Name, ' ', 1 ) , '_' , substring(Last_name , 1 , 2) , '.' , substring(type , 1 , 1) , '@usb.com' );
 CALL view;
 
 
 -- ###################################################################################################################
-- EXPORTAR NUESTRO SET DE DATOS
-- ###################################################################################################################


-- tabla definitiva
SELECT Id_Empleado, Name, Last_name, age, Gender, area, salary, email, finish_date FROM limpieza 
WHERE finish_date <= curdate() OR  finish_date is null
ORDER BY area , Last_name;

-- Cantidad de empleados
SELECT area, count(*) AS cantidad_empleados FROM limpieza
GROUP BY area
ORDER BY cantidad_empleados DESC;