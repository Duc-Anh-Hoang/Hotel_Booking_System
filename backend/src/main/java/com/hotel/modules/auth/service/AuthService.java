package com.hotel.modules.auth.service;

import com.hotel.common.config.JwtService;
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
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
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
    public Map<String, String> register(String fullName,
                                        String email,
                                        String password,
                                        String phone) {
        // Kiểm tra email đã tồn tại chưa
        if (userRepository.existsByEmail(email)) {
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
                .fullName(fullName)
                .email(email)
                .passwordHash(passwordEncoder.encode(password))
                .phone(phone)
                .roles(roles)
                .isActive(true)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        userRepository.save(user);

        // Tạo token sau khi đăng ký
        String token = jwtService.generateAccessToken(user);
        Map<String, String> result = new HashMap<>();
        result.put("token", token);
        result.put("message", "Đăng ký thành công!");
        return result;
    }

    // ── Đăng nhập ─────────────────────────────────────────
    public Map<String, String> login(String email, String password) {
        // Spring Security tự kiểm tra email + password
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(email, password)
        );

        // Lấy user từ DB
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản!"));

        // Tạo token
        String token = jwtService.generateAccessToken(user);

        Map<String, String> result = new HashMap<>();
        result.put("token", token);
        result.put("email", user.getEmail());
        result.put("fullName", user.getFullName());
        return result;
    }
}