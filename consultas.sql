-- 1. ¿Qué usuarios han realizado más de 2 solicitudes y han recibido una calificación menor a 3?
SELECT  U.nombreCompleto, COUNT(S.idsolicitud) AS totalSolHechas, 
MIN(C.puntuacion) AS peorCalificacion
FROM USUARIO AS U
JOIN SOLICITUD AS S ON U.idusuario = S.idusuario
JOIN RESPUESTA AS R ON S.idsolicitud = R.idsolicitud
JOIN CALIFICACION C ON R.idrespuesta = C.idrespuesta
GROUP BY U.idusuario, U.nombreCompleto
HAVING COUNT(S.idsolicitud) > 2 AND MIN(C.puntuacion) IN ('1', '2');

-- 2. ¿Qué administradores han respondido más solicitudes que el promedio?
SELECT A.idadmin, A.usuario AS usuarioAdmin, COUNT(R.idrespuesta) AS totalRespuestas
FROM ADMIN AS A
JOIN RESPUESTA AS R ON A.idadmin = R.idadmin
GROUP BY A.idadmin
HAVING totalRespuestas > (SELECT AVG(totalResp)
			FROM (SELECT COUNT(R.idrespuesta) AS totalResp
					FROM RESPUESTA AS R GROUP BY R.idadmin) AS promRespuestas);

-- 3. ¿Cuál es el promedio general de calificaciones y el promedio de respuestas por solicitud?
SELECT 
    (SELECT ROUND(AVG(puntuacion), 2) FROM calificacion) AS promedio_general_calificaciones,
    (SELECT ROUND(AVG(conteo), 2) 
     FROM (SELECT COUNT(*) AS conteo 
           FROM respuesta 
           GROUP BY idsolicitud) AS temp) AS promedio_respuestas_por_solicitud;

-- 4. ¿Cuáles son las solicitudes que tienen más respuestas que el promedio del sistema?
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

-- 5. ¿Cuáles son los clientes con más quejas en el último mes?
SELECT u.nombreCompleto AS cliente, COUNT(*) AS total_quejas
FROM solicitud s
JOIN usuario u ON s.idusuario = u.idusuario
WHERE s.tipo = 'queja' 
AND s.fechaHoraCreacion >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) -- Último mes
GROUP BY u.idusuario, u.nombreCompleto
ORDER BY total_quejas DESC;

-- 6. ¿Qué clientes han registrado más reclamos en el sistema?
SELECT u.nombreCompleto AS cliente, COUNT(s.idsolicitud) AS total_quejas
FROM solicitud s
JOIN usuario u ON s.idusuario = u.idusuario
WHERE s.tipo = 'reclamo'
GROUP BY u.idusuario, u.nombreCompleto
ORDER BY total_quejas DESC;

-- 7. ¿Cuál es el tiempo promedio, mínimo y máximo de resolución de solicitudes con evidencia?
SELECT tipo, 
       AVG(TIMESTAMPDIFF(DAY, fechaHoraCreacion, fechaActualizacion)) AS tiempo_promedio_dias,
       MIN(TIMESTAMPDIFF(DAY, fechaHoraCreacion, fechaActualizacion)) AS tiempo_minimo_dias,
       MAX(TIMESTAMPDIFF(DAY, fechaHoraCreacion, fechaActualizacion)) AS tiempo_maximo_dias,
       COUNT(*) AS total_solicitudes_resueltas
FROM solicitud
WHERE estado = 'resuelta'
GROUP BY tipo
ORDER BY tiempo_promedio_dias DESC;

-- 8. ¿Qué administradores tienen más respuestas pendientes de contestar?
SELECT a.usuario, COUNT(r.idRespuesta) AS respuestas_pendientes
FROM admin a
JOIN respuesta r ON a.idAdmin = r.idAdmin
WHERE r.comentario IS NULL OR r.comentario = ''
GROUP BY a.idAdmin
ORDER BY respuestas_pendientes DESC;

-- 9. ¿Cuáles son los PQRS con la mayor cantidad de evidencias adjuntas?
SELECT 
    u.idusuario AS S.idsolicitud, 
     s.descripcion,  
    COUNT(e.id) AS total_evidencias
FROM Solicitud s
JOIN Evidencia e ON s.idsolicitud = e.idsolicitud
GROUP BY u.idusuario
ORDER BY total_evidencias DESC 
LIMIT 20; 

-- 10. ¿Cuales PQRS no han recibido respuesta en más de 15 días?
SELECT 
    u.idusuario AS S.idsolicitud, 
     s.descripcion, 
    s.fechaHoraCreacion
FROM Solicitud s
WHERE estado = 'resuelta' 
AND DATEDIFF(NOW(), s.fechaHoraCreacion) > 15;

