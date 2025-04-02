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
  `categoria` ENUM('servicios generales', 'seguridad', 'areas comunes') NOT NULL,
  `descripcion` LONGTEXT NOT NULL,
  `estado` ENUM('radicada', 'en proceso', 'resuelta', 'cerrada', 'reabierta') NOT NULL DEFAULT 'radicada',
  `fecha_hora_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
  `idusuario` INT NULL,
  PRIMARY KEY (`idsolicitud`),
  FOREIGN KEY (`idusuario`) REFERENCES `usuario`(`idusuario`)
);

-- Tabla de Respuestas a Solicitudes
CREATE TABLE `respuesta` (
  `idrespuesta` INT NOT NULL AUTO_INCREMENT,
  `ruta_oficio_pdf` VARCHAR(255) NULL,
  `comentario` TEXT NOT NULL,
  `fecha_respuesta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `puntuacion` INT CHECK (`puntuacion` BETWEEN 1 AND 5),
  `idsolicitud` INT NOT NULL,
  `idadmin` INT NOT NULL,
  `respuestaid` INT NULL,
  PRIMARY KEY (`idrespuesta`),
  FOREIGN KEY (`idsolicitud`) REFERENCES `solicitud`(`idsolicitud`),
  FOREIGN KEY (`idadmin`) REFERENCES `admin`(`idadmin`),
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

