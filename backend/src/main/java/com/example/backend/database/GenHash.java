package com.example.backend.database;

import org.springframework.security.crypto.bcrypt.BCrypt;

public class GenHash {
  public static void main(String[] args) {
    String hash = BCrypt.hashpw("admin123", BCrypt.gensalt(12)); // cost 12
    System.out.println(hash);
  }
}
