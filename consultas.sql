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
