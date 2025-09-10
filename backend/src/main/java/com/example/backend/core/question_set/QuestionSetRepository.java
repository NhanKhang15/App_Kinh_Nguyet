package com.example.backend.core.question_set;


import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface QuestionSetRepository extends JpaRepository<QuestionSet, Long> {
    // tìm theo tên (exact)
    QuestionSet findByName(String name);

    // search theo tên (LIKE, không phân biệt hoa/thường)
    Page<QuestionSet> findByNameContainingIgnoreCase(String name, Pageable pageable);

    Page<QuestionSet> findByIsActive(boolean isActive, Pageable pageable);
}
