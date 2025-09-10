package com.example.backend.core.answer;


import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

public class AnswerCreateDto {
    @NotNull
    public Long questionId;

    @Pattern(regexp = "^[A-Z]$")
    public String label;

    @NotBlank
    public String text;

    public String hint;

    public Integer orderInQuestion; // có thể null → sẽ auto set
}
