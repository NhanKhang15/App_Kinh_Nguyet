package com.example.backend.core.question;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface QuestionRepository extends JpaRepository<Question, Long> {
    Page<Question> findByQuestionTextContainingIgnoreCase(String q, Pageable pageable);
    Page<Question> findByQuestionSetIdAndIsActive(Long setId, boolean isActive, Pageable pageable);
    Page<Question> findByQuestionSetId(Long setId, Pageable pageable);

    // hàng xóm trước (max order < anchorOrder) trong 1 set
    @Query("""
        select max(q.orderInSet) from Question q
        where q.questionSetId = :setId and q.orderInSet < :anchorOrder
    """)
    Integer findPrevOrder(@Param("setId") Long setId, @Param("anchorOrder") Integer anchorOrder);

    // hàng xóm sau (min order > anchorOrder) trong 1 set
    @Query("""
        select min(q.orderInSet) from Question q
        where q.questionSetId = :setId and q.orderInSet > :anchorOrder
    """)
    Integer findNextOrder(@Param("setId") Long setId, @Param("anchorOrder") Integer anchorOrder);

    @Query("select max(q.orderInSet) from Question q where q.questionSetId = :setId")
    Integer findMaxOrderInSet(@Param("setId") Integer setId);

    boolean existsByQuestionSetIdAndOrderInSet(Integer setId, Integer orderInSet);
}
