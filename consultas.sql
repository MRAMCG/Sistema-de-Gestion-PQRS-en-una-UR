-- Personas con mas de 2 solicitudes y una calificacion menor a 3
SELECT  U.nombreCompleto, COUNT(S.idsolicitud) AS totalSolHechas, 
MIN(C.puntuacion) AS peorCalificacion
FROM USUARIO AS U
JOIN SOLICITUD AS S ON U.idusuario = S.idusuario
JOIN RESPUESTA AS R ON S.idsolicitud = R.idsolicitud
JOIN CALIFICACION C ON R.idrespuesta = C.idrespuesta
GROUP BY U.idusuario, U.nombreCompleto
HAVING COUNT(S.idsolicitud) > 2 AND MIN(C.puntuacion) IN ('1', '2');

-- Administradores que han respondido mas solicitudes que el promedio
SELECT A.idadmin, A.usuario AS usuarioAdmin, COUNT(R.idrespuesta) AS totalRespuestas
FROM ADMIN AS A
JOIN RESPUESTA AS R ON A.idadmin = R.idadmin
GROUP BY A.idadmin
HAVING totalRespuestas > (SELECT AVG(totalResp)
			FROM (SELECT COUNT(R.idrespuesta) AS totalResp
					FROM RESPUESTA AS R GROUP BY R.idadmin) AS promRespuestas);

-- Promedio general de calificaciones y promedio de respuestas por solicitud
SELECT 
    (SELECT ROUND(AVG(puntuacion), 2) FROM calificacion) AS promedio_general_calificaciones,
    (SELECT ROUND(AVG(conteo), 2) 
     FROM (SELECT COUNT(*) AS conteo 
           FROM respuesta 
           GROUP BY idsolicitud) AS temp) AS promedio_respuestas_por_solicitud;

-- Solicitudes con mas respuesta que el promedio
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

-- Clientes con mayor cantidad de quejas en el ultimo mes
SELECT u.nombreCompleto AS cliente, COUNT(*) AS total_quejas
FROM solicitud s
JOIN usuario u ON s.idusuario = u.idusuario
WHERE s.tipo = 'queja' 
AND s.fechaHoraCreacion >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) -- Último mes
GROUP BY u.idusuario, u.nombreCompleto
ORDER BY total_quejas DESC;

-- Clientes con mayor cantidad de reclamos 
SELECT u.nombreCompleto AS cliente, COUNT(s.idsolicitud) AS total_quejas
FROM solicitud s
JOIN usuario u ON s.idusuario = u.idusuario
WHERE s.tipo = 'reclamo'
GROUP BY u.idusuario, u.nombreCompleto
ORDER BY total_quejas DESC;

-- Tiempo promedio, minimo y maximo de las solicitudes con evidencia resueltas
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

-- Usuarios que han subido mas de 2 evidencias
SELECT u.idusuario, u.nombreCompleto, COUNT(e.idevidencia) AS total_evidencias
FROM Usuario u
JOIN Solicitud s ON u.idusuario = s.idusuario
JOIN Evidencia e ON s.idsolicitud = e.idsolicitud
GROUP BY u.idusuario
HAVING total_evidencias > 3
ORDER BY total_evidencias DESC;

-- Calificacion promedio de respuesta por tipo de solicitud
SELECT s.tipo, ROUND(AVG(c.puntuacion),2) AS calificacion_promedio
FROM Solicitud s
JOIN Respuesta r ON s.idsolicitud = r.idsolicitud
JOIN Calificacion c ON r.idrespuesta = c.idrespuesta
GROUP BY s.tipo
ORDER BY calificacion_promedio DESC;

