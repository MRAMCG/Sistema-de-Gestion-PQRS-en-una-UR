package com.apirest.backend.Service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import com.apirest.backend.Model.EstadoSolicitud;
import com.apirest.backend.Model.SolicitudModel;
import com.apirest.backend.Repository.ISolicitudRepository;

@Service
public class SolicitudProgramacion {
    private final ISolicitudRepository solicitudRepository;

    public SolicitudProgramacion(ISolicitudRepository solicitudRepository) {
        this.solicitudRepository = solicitudRepository;

    }

    @Scheduled(fixedRate = 5000)
    public void cerrarSolicitudesExpiradas (){
        LocalDateTime fechaLimite = LocalDateTime.now().minusSeconds(15);
        //Buscar solicitudes resueltas que no han sido reabiertas en 15 segundos
        List<SolicitudModel> SolicitudesExpiradas = solicitudRepository.findByEstadoAndFechaActualizacionBefore(EstadoSolicitud.RESUELTA, fechaLimite);

        for (SolicitudModel solicitud : SolicitudesExpiradas) {
            solicitud.setEstado(EstadoSolicitud.CERRADA);
            solicitudRepository.save(solicitud);
        }
        System.out.println("Solicitudes cerradas automáticamente: " + SolicitudesExpiradas.size());
    }
}
