package com.hotel.modules.auth.service;

import com.hotel.common.config.JwtService;
import com.hotel.modules.auth.dto.AuthResponse;
import com.hotel.modules.auth.dto.LoginRequest;
import com.hotel.modules.auth.dto.RegisterRequest;
import com.hotel.modules.auth.entity.Role;
import com.hotel.modules.auth.entity.User;
import com.hotel.modules.auth.repository.RoleRepository;
import com.hotel.modules.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    // ── Đăng ký ───────────────────────────────────────────
    public AuthResponse register(RegisterRequest request) {
        // Kiểm tra email đã tồn tại chưa
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email đã được sử dụng!");
        }

        // Lấy quyền CUSTOMER mặc định
        Role customerRole = roleRepository.findByRoleName("CUSTOMER")
                .orElseGet(() -> {
                    Role r = new Role();
                    r.setRoleName("CUSTOMER");
                    r.setDescription("Khách hàng mặc định");
                    return roleRepository.save(r);
                });
        Set<Role> roles = new HashSet<>();
        roles.add(customerRole);

        // Tạo user mới
        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .roles(roles)
                .isActive(true)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        userRepository.save(user);

        // Tạo token sau khi đăng ký
        String token = jwtService.generateAccessToken(user);
        return AuthResponse.builder()
                .token(token)
                .email(user.getEmail())
                .fullName(user.getFullName())
                .message("Đăng ký thành công!")
                .build();
    }

    // ── Đăng nhập ─────────────────────────────────────────
    public AuthResponse login(LoginRequest request) {
        // Spring Security tự kiểm tra email + password
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        // Lấy user từ DB
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản!"));

        // Tạo token
        String token = jwtService.generateAccessToken(user);

        return AuthResponse.builder()
                .token(token)
                .email(user.getEmail())
                .fullName(user.getFullName())
                .message("Đăng nhập thành công!")
                .build();
    }
}