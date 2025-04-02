package com.apirest.backend.Service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.apirest.backend.Exception.RecursoNoEncontradoException;
import com.apirest.backend.Model.SolicitudModel;
import com.apirest.backend.Repository.ISolicitudRepository;

@Service
public class SolicitudServiceImp implements ISolicitudService{
    @Autowired ISolicitudRepository solicitudRepository;

    @Override
    public SolicitudModel guardarSolicitud(SolicitudModel solicitud) {
        return solicitudRepository.save(solicitud);
    }

    @Override
    public List<SolicitudModel> listarSolicitudes() {
        return solicitudRepository.findAll();
    }

    @Override
    public SolicitudModel buscarSolicitudPorId(Integer id) {
        return solicitudRepository.findById(id).
        orElseThrow(()-> new RecursoNoEncontradoException("La solicitud con id "+id+", no fue encontrada o no existe."));
    }

    @Override
    public void eliminarSolicitudPorId(Integer id) {
        SolicitudModel solicitudExistente = buscarSolicitudPorId(id);
        solicitudRepository.delete(solicitudExistente);
    }

    @Override
    public SolicitudModel actualizarSolicitudPorId(Integer id, SolicitudModel solicitud) {
        SolicitudModel solicitudExistente = buscarSolicitudPorId(id);
        solicitudExistente.setIdSolicitud(solicitud.getIdSolicitud());
        return solicitudRepository.save(solicitudExistente);
    }
    
}
