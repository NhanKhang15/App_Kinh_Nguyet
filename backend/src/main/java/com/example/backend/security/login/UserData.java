package com.example.backend.security.login;

public class UserData {
    private final int userId;
    private final String email;
    private final String name;
    private final String role;
    private final boolean active;

    public UserData(int userId, String email, String name, String role, boolean active) {
        this.userId = userId;
        this.email = email;
        this.name = name;
        this.role = role;
        this.active = active;
    }
    public int getUserId() { return userId; }
    public String getEmail() { return email; }
    public String getName() { return name; }
    public String getRole() { return role; }
    public boolean isActive() { return active; }
}
