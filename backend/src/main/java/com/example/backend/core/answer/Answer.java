package com.example.backend.core.answer;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

@Entity
@Table(name = "Answers")
public class Answer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "question_id", nullable = false)
    @NotNull
    private Long questionId;

    // NCHAR(1) → String length=1
    @Column(name = "label", nullable = false, length = 1)
    @Pattern(regexp = "^[A-Z]$", message = "label must be A-Z (1 char)")
    private String label;

    // [text] NVARCHAR(MAX)
    @Column(name = "text", nullable = false, columnDefinition = "NVARCHAR(MAX)")
    @NotBlank
    private String text;

    @Column(name = "hint", columnDefinition = "NVARCHAR(MAX)")
    private String hint;

    // [order] INT NULL (đặt tên field khác để tránh nhầm với keyword)
    @Column(name = "order_in_question")
    private Integer orderInQuestion;

    // getters/setters
    public Long getId() { return id; }
    public Long getQuestionId() { return questionId; }
    public void setQuestionId(Long questionId) { this.questionId = questionId; }
    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
    public String getHint() { return hint; }
    public void setHint(String hint) { this.hint = hint; }
    public Integer getOrderInQuestion() { return orderInQuestion; }
    public void setOrderInQuestion(Integer orderInQuestion) { this.orderInQuestion = orderInQuestion; }
}
