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
            