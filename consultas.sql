-- Personas con mas de 2 solicitudes y una calificacion menor a 3

select  u.nombreCompleto, count(s.idsolicitud) as totalSolHechas, 
min(c.puntuacion) as peorCalificacion
from usuario as u
join solicitud as s on u.idusuario = s.idusuario
join respuesta as r on s.idsolicitud = r.idsolicitud
join calificacion c on r.idrespuesta = c.idrespuesta
group by u.idusuario, u.nombreCompleto
having count(s.idsolicitud) > 2 and min(c.puntuacion) in ('1', '2');

-- Administradores que han respondido más solicitudes que el promedio

select a.idadmin, a.usuario as usuarioAdmin, count(r.idrespuesta) as totalRespuestas
from admin as a
join respuesta as r on a.idadmin = r.idadmin
group by a.idadmin
having totalRespuestas > (select avg(totalResp)
			from (select count(r.idrespuesta) as totalResp
					from respuesta as r group by r.idadmin) as promRespuestas);

-- Promedio general de todas las calificaciones
SELECT 'Promedio General' AS grupo, 
       NULL AS subgrupo, 
       AVG(puntuacion) AS promedio, 
       COUNT(*) AS total_calificaciones
FROM calificacion

UNION

-- se calcula el promedio de respuestas por solicitud
SELECT @promedio := AVG(conteo) 
FROM (
    SELECT COUNT(*) as conteo
    FROM respuesta
    GROUP BY idsolicitud
) AS temp;

-- se selecciona las solicitudes que tienen más respuestas que ese promedio
SELECT 
    s.idsolicitud,
    s.tipo,
    s.descripcion,
    s.estado,
    COUNT(r.idrespuesta) AS num_respuestas,
    @promedio AS promedio_sistema
FROM solicitud s
JOIN respuesta r ON s.idsolicitud = r.idsolicitud
GROUP BY s.idsolicitud
HAVING COUNT(r.idrespuesta) > @promedio
ORDER BY num_respuestas DESC;

-- ¿Cuáles son los clientes con mas quejas durante el ultimo mes?
SELECT c.nombre, sub.total_quejas
FROM (
    SELECT cliente_id, COUNT(*) AS total_quejas
    FROM quejas
    WHERE fecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)  -- Filtra quejas del último mes
    GROUP BY cliente_id
) AS sub
JOIN clientes c ON sub.cliente_id = c.id
ORDER BY sub.total_quejas DESC;

-- ¿Cuáles son los nombres de los clientes con más quejas registradas, considerando todos los que tienen una cantidad de quejas dentro del top 10?
SELECT c.nombre, COUNT(q.id) AS total_quejas
FROM quejas q
JOIN clientes c ON q.cliente_id = c.id
GROUP BY c.nombre
HAVING COUNT(q.id) >= (
    SELECT COUNT(*) 
    FROM quejas 
    GROUP BY cliente_id 
    ORDER BY COUNT(*) DESC 
)
ORDER BY total_quejas DESC;

-- Tiempo promedio de resolución de solicitudes resueltas con evidencia
SELECT tipo, 
       AVG(TIMESTAMPDIFF(DAY, fechaHoraCreacion, fechaActualizacion)) AS tiempo_promedio_dias,
       MIN(TIMESTAMPDIFF(DAY, fechaHoraCreacion, fechaActualizacion)) AS tiempo_minimo_dias,
       MAX(TIMESTAMPDIFF(DAY, fechaHoraCreacion, fechaActualizacion)) AS tiempo_maximo_dias,
       COUNT(*) AS total_solicitudes_resueltas
FROM solicitud
WHERE estado = 'resuelta'
GROUP BY tipo
ORDER BY tiempo_promedio_dias DESC;

-- Administradores con más respuestas sin contestar
SELECT a.usuario, COUNT(r.idRespuesta) AS respuestas_pendientes
FROM admin a
JOIN respuesta r ON a.idAdmin = r.idAdmin
WHERE r.comentario IS NULL OR r.comentario = ''
GROUP BY a.idAdmin
ORDER BY respuestas_pendientes DESC;

