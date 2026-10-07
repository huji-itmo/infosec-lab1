package com.infosec.lab1.config;

import com.infosec.lab1.model.Role;
import com.infosec.lab1.model.User;
import com.infosec.lab1.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public DataInitializer(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        if (!userRepository.existsByUsername("admin")) {
            User admin = new User(
                    "admin",
                    passwordEncoder.encode("admin123"),
                    "Administrator",
                    "admin@infosec.local",
                    Role.ADMIN
            );
            userRepository.save(admin);
            log.info("Created test user: admin (password is configured for local development only)");
        }

        if (!userRepository.existsByUsername("user1")) {
            User user = new User(
                    "user1",
                    passwordEncoder.encode("password1"),
                    "User One",
                    "user1@infosec.local",
                    Role.USER
            );
            userRepository.save(user);
            log.info("Created test user: user1 (password is configured for local development only)");
        }
    }
}
