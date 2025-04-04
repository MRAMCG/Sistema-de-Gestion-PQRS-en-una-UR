-- Personas con mas de 2 solicitudes y una calificacion menor a 3
SELECT  U.nombre_completo, COUNT(S.idsolicitud) AS totalSolHechas, 
MIN(R.puntuacion) AS peorCalificacion
FROM usuario AS U
INNER JOIN solicitud AS S USING (idusuario)
INNER JOIN respuesta AS R USING (idsolicitud)
GROUP BY U.idusuario, U.nombre_completo
HAVING COUNT(S.idsolicitud) > 2 AND MIN(R.puntuacion) IN (1, 2);

-- Administradores que han respondido mas solicitudes que el promedio
SELECT A.idadmin, A.usuario AS usuarioAdmin, COUNT(R.idrespuesta) AS totalRespuestas
FROM admin AS A
INNER JOIN respuesta AS R USING (idadmin)
GROUP BY A.idadmin
HAVING totalRespuestas > (SELECT AVG(totalResp)
            FROM (SELECT COUNT(R.idrespuesta) AS totalResp
                    FROM respuesta GROUP BY idadmin) AS promRespuestas);

-- Promedio general de calificaciones y promedio de respuestas por solicitud
SELECT (SELECT ROUND(AVG(puntuacion), 2) FROM respuesta) AS promedio_general_calificaciones,
    (SELECT ROUND(AVG(conteo), 2) 
     FROM (SELECT COUNT(*) AS conteo 
           FROM respuesta 
           GROUP BY idsolicitud) AS temp) AS promedio_respuestas_por_solicitud;

-- Solicitudes con mas respuestas que el promedio
SELECT 
    s.idsolicitud,
    s.tipo,
    s.descripcion,
    s.estado,
    COUNT(r.idrespuesta) AS num_respuestas,
    (SELECT AVG(conteo) FROM (SELECT COUNT(*) AS conteo FROM respuesta GROUP BY idsolicitud) AS promedio_sistema) AS promedio_sistema
FROM solicitud s
INNER JOIN respuesta r USING (idsolicitud)
GROUP BY s.idsolicitud
HAVING COUNT(r.idrespuesta) > promedio_sistema
ORDER BY num_respuestas DESC;

-- Clientes con mayor cantidad de quejas en el ultimo mes
SELECT u.nombre_completo AS cliente, COUNT(*) AS total_quejas
FROM solicitud s
INNER JOIN usuario u USING (idusuario)
WHERE s.tipo = 'queja' 
AND s.fecha_hora_creacion >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY u.idusuario, u.nombre_completo
ORDER BY total_quejas DESC;

-- Clientes con mayor cantidad de reclamos
SELECT u.nombre_completo AS cliente, COUNT(s.idsolicitud) AS total_reclamos
FROM solicitud s
INNER JOIN usuario u USING (idusuario)
WHERE s.tipo = 'reclamo'
GROUP BY u.idusuario, u.nombre_completo
ORDER BY total_reclamos DESC;

-- Tiempo promedio, minimo y maximo de las solicitudes con evidencia resueltas
SELECT tipo, 
       AVG(TIMESTAMPDIFF(DAY, fecha_hora_creacion, fecha_actualizacion)) AS tiempo_promedio_dias,
       MIN(TIMESTAMPDIFF(DAY, fecha_hora_creacion, fecha_actualizacion)) AS tiempo_minimo_dias,
       MAX(TIMESTAMPDIFF(DAY, fecha_hora_creacion, fecha_actualizacion)) AS tiempo_maximo_dias,
       COUNT(*) AS total_solicitudes_resueltas
FROM solicitud
WHERE estado = 'resuelta'
GROUP BY tipo
ORDER BY tiempo_promedio_dias DESC;

-- Administradores con el mayor numero de respuestas registradas
SELECT a.usuario, COUNT(r.idrespuesta) AS total_respuestas
FROM admin a
INNER JOIN respuesta r USING (idadmin)
GROUP BY a.idadmin
ORDER BY total_respuestas DESC
LIMIT 5;

-- Usuarios que han subido mas de 3 evidencias
SELECT u.idusuario, u.nombre_completo, COUNT(e.idevidencia) AS total_evidencias
FROM usuario u
INNER JOIN solicitud s USING (idusuario)
INNER JOIN evidencia e USING (idsolicitud)
GROUP BY u.idusuario
HAVING total_evidencias > 3
ORDER BY total_evidencias DESC;

-- Calificacion promedio de respuesta por tipo de solicitud
SELECT s.tipo, ROUND(AVG(r.puntuacion),2) AS calificacion_promedio
FROM solicitud s
INNER JOIN respuesta r USING (idsolicitud)
GROUP BY s.tipo
ORDER BY calificacion_promedio DESC;
