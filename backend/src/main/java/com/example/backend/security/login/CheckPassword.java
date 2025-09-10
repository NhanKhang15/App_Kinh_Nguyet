package com.example.backend.security.login;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.stereotype.Component;

import com.example.backend.database.DBConnection;

@Component
public class CheckPassword {
    @Autowired
    private DBConnection dbConnection;

    // Cho phép username là name hoặc email
    private static final String SQL =
        "SELECT user_id, email, name, password_hashed, role, active " +
        "FROM Users WHERE (name = ? OR email = ?)";

    public UserData check(String username, String passwordInput) {
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SQL)) {

            stmt.setString(1, username);
            stmt.setString(2, username);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String passwordInDb = rs.getString("password_hashed");
                if (BCrypt.checkpw(passwordInput, passwordInDb)) {
                    boolean active = rs.getBoolean("active");
                    if (!active) {
                        System.out.println("⚠️ Tài khoản bị khóa: " + rs.getString("name"));
                        return null;
                    }
                    System.out.println("✅ Đăng nhập thành công: " + LocalDateTime.now());
                    return new UserData(
                        rs.getInt("user_id"),
                        rs.getString("email"),
                        rs.getString("name"),
                        rs.getString("role"),
                        active
                    );
                } else {
                    System.out.println("❌ Sai mật khẩu!");
                }
            } else {
                System.out.println("⚠️ Không tìm thấy người dùng: " + username);
            }
        } catch (Exception e) {
            System.err.println("❌ Lỗi kiểm tra mật khẩu: " + e.getMessage());
        }
        return null;
    }
}
