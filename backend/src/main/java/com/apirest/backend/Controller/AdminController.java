package com.sistemagestionur.controller;

import com.sistemagestionur.model.Admin;
import com.sistemagestionur.repository.AdminRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/admins")
public class AdminController {

    @Autowired
    private AdminRepository adminRepository;

    // GET /admins
    @GetMapping
    public List<Admin> getAll() {
        return adminRepository.findAll();
    }

    // GET /admins/1
    @GetMapping("/{id}")
    public ResponseEntity<Admin> getById(@PathVariable Integer id) {
        return adminRepository.findById(id)
                .map(admin -> ResponseEntity.ok(admin))
                .orElse(ResponseEntity.notFound().build());
    }

    // POST /admins (crear)
    @PostMapping
    public Admin create(@RequestBody Admin admin) {
        return adminRepository.save(admin);
    }

    // POST /admins/login (login)
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Admin admin) {
        Optional<Admin> encontrado = adminRepository.findByUsuarioAndContrasena(
                admin.getUsuario(), admin.getContrasena());

        if (encontrado.isPresent()) {
            return ResponseEntity.ok(encontrado.get());
        } else {
            return ResponseEntity.status(401).body("Credenciales incorrectas");
        }
    }
}
