package com.apirest.backend.Controller;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.apirest.backend.Model.EvidenciaModel;
import com.apirest.backend.Model.SolicitudModel;
import com.apirest.backend.Model.UsuarioModel;
import com.apirest.backend.Service.ISolicitudService;
import com.apirest.backend.Service.IUsuarioService;
import com.apirest.backend.Service.IEvidenciaService;

@RestController
@RequestMapping ("UR/solicitudes")

public class SolicitudController {
    @Autowired ISolicitudService solicitudService;
    @Autowired IEvidenciaService evidenciaService;
    @Autowired
    private IUsuarioService usuarioService;
    @PostMapping("/insertar")
    public ResponseEntity<?> guardarSolicitud(@RequestBody SolicitudModel solicitud) {
        Integer idUsuario = solicitud.getUsuario().getIdUsuario(); 
        var usuario = usuarioService.buscarUsuarioPorId(idUsuario);

        if (usuario == null) {
            return ResponseEntity.badRequest().body("Usuario no válido");
        }
        
        if (usuario.getRol().name().equals("ANONIMO")) {
            System.out.println("Solicitud hecha por un usuario anónimo");
        }

        solicitud.setUsuario(usuario);

        return new ResponseEntity<>(solicitudService.guardarSolicitud(solicitud), HttpStatus.CREATED);
    }

    @GetMapping ("/listar")
    public ResponseEntity<List<SolicitudModel>> listarSolicitudes() {
        return new ResponseEntity<List<SolicitudModel>>(solicitudService.listarSolicitudes(),HttpStatus.OK);
    }

    @GetMapping ("/buscarporid/{id}")
    public ResponseEntity<SolicitudModel> buscarSolicitudPorId(@PathVariable Integer id) {
        return new ResponseEntity<SolicitudModel>(solicitudService.buscarSolicitudPorId(id),HttpStatus.OK);
    }

    @PutMapping ("/actualizar/{id}")
    public ResponseEntity<SolicitudModel> actualizarCategoriaPorId(@PathVariable Integer id, @RequestBody SolicitudModel solicitud){
        return new ResponseEntity<>(solicitudService.actualizarSolicitudPorId(id, solicitud),HttpStatus.OK);
    }
    
    @DeleteMapping ("eliminar/{id}")
    public ResponseEntity<Void> eliminarSolicitudPorId(@PathVariable Integer id){
        solicitudService.eliminarSolicitudPorId(id);
            return ResponseEntity.noContent().build();
    }

    @PostMapping (value = "{id}/evidencias", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> guardarEvidencia(
        @PathVariable Integer id,
        @RequestParam("archivo") MultipartFile archivo,
        @RequestParam("idUsuario") Integer idUsuario,
        @RequestParam(value = "descripcion", required = false) String descripcion
    ) {
        if (archivo.isEmpty()) {
            return ResponseEntity.badRequest().body("Archivo no puede estar vacío");
        }

        UsuarioModel usuario = usuarioService.buscarUsuarioPorId(idUsuario);
        if (usuario == null) {
            return ResponseEntity.badRequest().body("Usuario no válidos");
        }

        SolicitudModel solicitud = solicitudService.buscarSolicitudPorId(id);
        if (solicitud == null) {
            return ResponseEntity.badRequest().body("Solicitud no válidos");
        }

        if (solicitud.getUsuario() != usuario) {
            return ResponseEntity.badRequest().body("Solicitud no pertenece al usuario");
        }
        
        try {
            EvidenciaModel evidencia = new EvidenciaModel();
            
            evidencia.setDescripcion(descripcion);
            evidencia.setSolicitud(solicitud);
            evidencia.setFecha_hora_carga(LocalDateTime.now());

            EvidenciaModel evidenciaGuardada = evidenciaService.guardarEvidencia(evidencia, archivo);

            return ResponseEntity.status(HttpStatus.CREATED).body(evidenciaGuardada);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().body("Error al procesar archivo: "+ e.getMessage());
        }
    }

    @GetMapping (value = "{id}/evidencias")
    public ResponseEntity<?> obtenerEvidenciasSolicitud(@PathVariable Integer id) {
        SolicitudModel solicitud = solicitudService.buscarSolicitudPorId(id);
        if (solicitud == null) {
            return ResponseEntity.badRequest().body("Solicitud no válidos");
        }

        return new ResponseEntity<List<EvidenciaModel>>(evidenciaService.obtenerEvidenciasPorSolicitud(solicitud), HttpStatus.OK);
    }
}