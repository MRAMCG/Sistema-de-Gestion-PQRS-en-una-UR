package com.sistemagestionur.repository;

import com.sistemagestionur.model.Admin;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AdminRepository extends JpaRepository<Admin, Integer> {
    Optional<Admin> findByUsuarioAndContrasena(String usuario, String contrasena);
