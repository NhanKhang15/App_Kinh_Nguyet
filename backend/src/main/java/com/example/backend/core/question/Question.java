package com.example.backend.core.question;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Questions")
public class Question {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "question_set_id", nullable = false)
    private Integer questionSetId;

    // "text" là tên cột trong DB; field đặt là questionText cho clear
    @Column(name = "text", nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String questionText;

    // "type" là tên cột trong DB
    @Column(name = "type", nullable = false, length = 20)
    private String type; // 'single' | 'multiple' | 'text'

    @Column(name = "order_in_set", nullable = false)
    private Integer orderInSet;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    // getters/setters
    public Long getId() { return id; }
    public Integer getQuestionSetId() { return questionSetId; }
    public void setQuestionSetId(Integer v) { this.questionSetId = v; }
    public String getQuestionText() { return questionText; }
    public void setQuestionText(String v) { this.questionText = v; }
    public String getType() { return type; }
    public void setType(String v) { this.type = v; }
    public Integer getOrderInSet() { return orderInSet; }

    public void setOrderInSet(Integer v) { this.orderInSet = v; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean v) { this.isActive = v; }
    
}

