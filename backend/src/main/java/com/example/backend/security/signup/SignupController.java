package com.example.backend.security.signup;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@CrossOrigin(origins = "*")
public class SignupController {

    @Autowired
    private Signup signup;

    @PostMapping("/signup")
    public Map<String, Object> signup(@RequestBody SignupRequest request) {
        boolean success = signup.register(request);

        Map<String, Object> res = new HashMap<>();
        res.put("success", success);
        res.put("message", success ? "Đăng ký thành công!" : "Đăng ký thất bại. Có thể user/email đã tồn tại!");

        return res;
    }
}