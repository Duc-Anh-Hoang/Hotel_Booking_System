package com.hotel.modules.auth.controller;

import com.hotel.modules.auth.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    // POST /api/v1/auth/register
    @PostMapping("/register")
    public ResponseEntity<Map<String, String>> register(
            @RequestBody Map<String, String> body) {
        Map<String, String> result = authService.register(
                body.get("fullName"),
                body.get("email"),
                body.get("password"),
                body.get("phone")
        );
        return ResponseEntity.ok(result);
    }

    // POST /api/v1/auth/login
    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(
            @RequestBody Map<String, String> body) {
        Map<String, String> result = authService.login(
                body.get("email"),
                body.get("password")
        );
        return ResponseEntity.ok(result);
    }
}