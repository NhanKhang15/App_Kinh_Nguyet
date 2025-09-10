package com.example.backend.security.signup;

import java.sql.Connection;
import java.sql.PreparedStatement;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.backend.database.DBConnection;

@Service
public class Signup {

    @Autowired
    private DBConnection dbConnection;

    @Autowired
    private HashPassword hashPassword;

    public boolean register(SignupRequest request) {
        String insertQuery = "INSERT INTO Users (name, email, password_hashed, phone) VALUES (?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(insertQuery)) {

            String hashed = hashPassword.hash(request.getPassword());

            stmt.setString(1, request.getUsername());
            stmt.setString(2, request.getEmail());
            stmt.setString(3, hashed);
            stmt.setString(4, request.getPhoneNumber());

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;

        } catch (Exception e) {
            System.err.println("❌ Đăng ký thất bại: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
