package com.infosec.lab1.service;

import com.infosec.lab1.dto.LoginRequest;
import com.infosec.lab1.dto.LoginResponse;
import com.infosec.lab1.model.Role;
import com.infosec.lab1.model.User;
import com.infosec.lab1.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    public LoginResponse authenticate(LoginRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new SecurityException("Invalid username or password"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new SecurityException("Invalid username or password");
        }

        String token = jwtService.generateToken(user.getUsername(), user.getRole().name());

        return new LoginResponse(
                token,
                user.getUsername(),
                user.getDisplayName(),
                user.getRole().name()
        );
    }
}