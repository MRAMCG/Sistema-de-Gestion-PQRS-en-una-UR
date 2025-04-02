package com.apirest.backend.Controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.apirest.backend.Model.SolicitudModel;
import com.apirest.backend.Service.ISolicitudService;

@RestController
@RequestMapping ("UR/solicitudes")

public class solicitudController {
    @Autowired ISolicitudService solicitudService;
    
    @PostMapping ("/insertar")
    public ResponseEntity <SolicitudModel> guardarSolicitud(@RequestBody SolicitudModel solicitud) {
        return new ResponseEntity<SolicitudModel>(solicitudService.guardarSolicitud(solicitud),HttpStatus.CREATED);
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

}
