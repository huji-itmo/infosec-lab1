package com.infosec.lab1.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Pattern;

public class UpdateProfileRequest {

    @Size(max = 100, message = "Display name must be at most 100 characters")
    @Pattern(regexp = "[^<>]*", message = "Display name must not contain HTML tags")
    private String displayName;

    @Email(message = "Email must be valid")
    @Size(max = 150, message = "Email must be at most 150 characters")
    private String email;

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
