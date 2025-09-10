package com.example.backend.security.login;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@CrossOrigin(origins = "*")
public class Login {
    @Autowired
    private CheckPassword checkPassword;

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody LoginRequest request) {
        UserData info = checkPassword.check(request.getUsername(), request.getPassword());
        boolean success = (info != null); // hơi ngoooo

        Map<String, Object> response = new HashMap<>();
        response.put("success", success);
        response.put("message", success ? "Login thành công!!!!" : "Sai tài khoản hoặc mật khẩu!");
        response.put("user_id", success ? info.getUserId() : 0);
        response.put("username", success ? request.getUsername() : "null");
        response.put("role", success ? info.getRole() : "null");
        response.put("active", success ? info.isActive() : "null");
        response.put("email", success ? info.getEmail() : "null");
        
        return response;
    }    
}
