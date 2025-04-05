package com.sistemagestionur.model;

import jakarta.persistence.*;

@Entity
@Table(name = "admin")
public class Admin {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idadmin;

    private String usuario;
    private String contrasena;

    // Getters y Setters
    public Integer getIdadmin() { return idadmin; }
    public void setIdadmin(Integer idadmin) { this.idadmin = idadmin; }

    public String getUsuario() { return usuario; }
    public void setUsuario(String usuario) { this.usuario = usuario; }

    public String getContrasena() { return contrasena; }
    public void setContrasena(String contrasena) { this.contrasena = contrasena; }
}
