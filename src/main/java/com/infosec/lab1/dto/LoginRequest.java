package com.infosec.lab1.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Pattern;

public class LoginRequest {

    @NotBlank(message = "Username is required")
    @Size(max = 50, message = "Username must be at most 50 characters")
    @Pattern(regexp = "[A-Za-z0-9_.-]+", message = "Username contains invalid characters")
    private String username;

    @NotBlank(message = "Password is required")
    @Size(max = 128, message = "Password must be at most 128 characters")
    private String password;

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
