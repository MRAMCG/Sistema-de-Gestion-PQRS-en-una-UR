CREATE SCHEMA `SistemaGestionUR`;
USE `SistemaGestionUR`;

-- Tabla de Usuarios
CREATE TABLE `usuario` (
  `idusuario` INT NOT NULL AUTO_INCREMENT,
  `usuario` VARCHAR(15) NOT NULL UNIQUE,
  `nombre_completo` VARCHAR(100) NOT NULL,
  `tipo_documento` VARCHAR(100) NULL,
  `numero_documento` VARCHAR(45) UNIQUE NULL,
  `correo_electronico` VARCHAR(100) UNIQUE NULL,
  `telefono` VARCHAR(20) NULL,
  `direccion_interna` VARCHAR(100) NULL,
  `rol` ENUM('propietario', 'inquilino', 'anonimo') NOT NULL,
  `contrasena` VARCHAR(25) NULL,
  PRIMARY KEY (`idusuario`),
  CHECK (
    (rol = 'anonimo' AND nombre_completo = 'Anónimo' AND tipo_documento IS NULL AND 
     numero_documento IS NULL AND correo_electronico IS NULL AND telefono IS NULL AND 
     direccion_interna IS NULL) 
    OR 
    (rol IN ('propietario', 'inquilino'))
  )
);

-- Tabla de Administradores
CREATE TABLE `admin` (
  `idadmin` INT NOT NULL AUTO_INCREMENT,
  `usuario` VARCHAR(45) NOT NULL UNIQUE,
  `contrasena` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`idadmin`)
);

-- Tabla de Solicitudes PQRS
CREATE TABLE `solicitud` (
  `idsolicitud` INT NOT NULL AUTO_INCREMENT,
  `tipo` ENUM('peticion', 'queja', 'reclamo', 'sugerencia') NOT NULL,
  `categoria` ENUM('serviciosGenerales', 'seguridad', 'areasComunes') NOT NULL,
  `descripcion` LONGTEXT NOT NULL,
  `estado` ENUM('radicada', 'enProceso', 'resuelta', 'cerrada', 'reabierta') NOT NULL DEFAULT 'radicada',
  `fecha_hora_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  `idusuario` INT NOT NULL,
  PRIMARY KEY (`idsolicitud`),
  FOREIGN KEY (`idusuario`) REFERENCES `usuario`(`idusuario`)
);

-- Tabla de Respuestas 
CREATE TABLE `respuesta` (
  `idrespuesta` INT NOT NULL AUTO_INCREMENT,
  `ruta_oficio_pdf` VARCHAR(255) NULL,
  `comentario` TEXT NOT NULL,
  `fecha_respuesta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `puntuacion` INT CHECK (`puntuacion` BETWEEN 1 AND 5),
  `idsolicitud` INT NOT NULL,
  `idadmin` INT NULL,
  `idusuario` INT NULL,
  `respuestaid` INT NULL,
  PRIMARY KEY (`idrespuesta`),
  FOREIGN KEY (`idsolicitud`) REFERENCES `solicitud`(`idsolicitud`),
  FOREIGN KEY (`idadmin`) REFERENCES `admin`(`idadmin`),
  FOREIGN KEY (`idusuario`) REFERENCES `usuario`(`idusuario`),
  FOREIGN KEY (`respuestaid`) REFERENCES `respuesta`(`idrespuesta`)
);

-- Tabla de Evidencias Adjuntas
CREATE TABLE `evidencia` (
  `idevidencia` INT NOT NULL AUTO_INCREMENT,
  `tipo_archivo` ENUM('pdf', 'video', 'imagen', 'audio', 'otro') NOT NULL,
  `rutaarchivo` VARCHAR(255) NULL,
  `descripcion` TEXT NULL,
  `fecha_hora_carga` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idsolicitud` INT NOT NULL,
  PRIMARY KEY (`idevidencia`),
  FOREIGN KEY (`idsolicitud`) REFERENCES `solicitud`(`idsolicitud`)
);

-- OBJETOS ALMACENADOS
USE `SistemaGestionUR`;

-- Trigger: impedir modificar solicitudes cerradas

DELIMITER //

CREATE TRIGGER evitarCambiosSiCerrada
BEFORE UPDATE ON solicitud
FOR EACH ROW
BEGIN
    IF OLD.estado = 'cerrada' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede modificar una solicitud cerrada.';
    END IF;
END;
//

DELIMITER ;

-- Trigger: Validar que los usuarios anónimos no tengan datos personales

DELIMITER $$

CREATE TRIGGER validarUsuarioAnonimo
BEFORE INSERT ON usuario
FOR EACH ROW
BEGIN
  IF NEW.rol = 'anonimo' THEN
    SET NEW.nombre_completo = 'Anónimo',
        NEW.tipo_documento = NULL,
        NEW.numero_documento = NULL,
        NEW.correo_electronico = NULL,
        NEW.telefono = NULL,
        NEW.direccion_interna = NULL;
  END IF;
END$$

-- Trigger: garantizar que la puntuacion sea entre 1 y 5
DELIMITER $$

CREATE TRIGGER validar_puntuacion_respuesta
BEFORE INSERT ON respuesta
FOR EACH ROW
BEGIN
  IF NEW.puntuacion IS NOT NULL AND (NEW.puntuacion < 1 OR NEW.puntuacion > 5) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'La puntuación debe estar entre 1 y 5';
  END IF;
END$$

DELIMITER ;

-- Trigger pasar a resuelta cuando un admin responde
DELIMITER $$

CREATE TRIGGER marcarComoResueltaPorAdmin
AFTER INSERT ON respuesta
FOR EACH ROW
BEGIN
  IF NEW.idadmin IS NOT NULL AND NEW.respuestaid IS NULL THEN
    UPDATE solicitud
    SET estado = 'resuelta',
        fecha_actualizacion = NOW()
    WHERE idsolicitud = NEW.idsolicitud;
  END IF;
END$$

DELIMITER ;

-- Evento: cerrar solicitud tras 15 segundos
CREATE EVENT cerrarSolicitudesSinReplica
ON SCHEDULE EVERY 15 SECOND
DO
  UPDATE solicitud s
  SET s.estado = 'cerrada',
      s.fecha_actualizacion = NOW()
  WHERE s.estado = 'resuelta'
    AND NOT EXISTS (
      SELECT 1
      FROM respuesta r
      JOIN usuario u ON u.idusuario = r.idusuario
      WHERE r.idsolicitud = s.idsolicitud
        AND u.rol IN ('propietario', 'inquilino')
    );

-- Trigger validad que no son anonimos par replicar

DELIMITER $$

CREATE TRIGGER validarReplicaPorRol
BEFORE INSERT ON respuesta
FOR EACH ROW
BEGIN
  DECLARE user_rol VARCHAR(20);

  -- Solo si es una respuesta con idusuario (replica)
  IF NEW.idusuario IS NOT NULL THEN
    SELECT rol INTO user_rol
    FROM usuario
    WHERE idusuario = NEW.idusuario;

    IF user_rol = 'anonimo' THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Los usuarios anónimos no pueden enviar réplicas.';
    END IF;
  END IF;
END$$

DELIMITER ;

-- Procedimiento: Reabrir solicitud 
DELIMITER $$

CREATE PROCEDURE reabrirSolicitud(
  IN p_idsolicitud INT,
  IN p_comentario TEXT
)
BEGIN
  UPDATE solicitud
  SET estado = 'reabierta',
      fecha_actualizacion = NOW()
  WHERE idsolicitud = p_idsolicitud;

  INSERT INTO respuesta (comentario, idsolicitud, idadmin)
  VALUES (p_comentario, p_idsolicitud, NULL);
END$$

DELIMITER ;

-- Procedimiento: cantidad de solicitudes por estado y por categoria
DELIMITER $$

CREATE PROCEDURE obtenerEstadisticasPqrs()
BEGIN
  SELECT 
    categoria,
    estado,
    COUNT(*) AS cantidad
  FROM solicitud
  GROUP BY categoria, estado
  ORDER BY categoria, estado;
END$$

DELIMITER ;
