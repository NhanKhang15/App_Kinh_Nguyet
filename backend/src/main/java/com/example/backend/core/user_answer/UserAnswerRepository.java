package com.example.backend.core.user_answer;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface UserAnswerRepository extends JpaRepository<SubmitAnswerRequest, Long> {

    // ---- 1) Check: answer có thuộc question không? ----
    // Dùng native @Query, không PreparedStatement thuần.
    @Query(
        value = """
            SELECT CASE WHEN EXISTS (
                SELECT 1
                  FROM dbo.Answers a
                 WHERE a.id = :answerId
                   AND a.question_id = :questionId
            ) THEN 1 ELSE 0 END
            """,
        nativeQuery = true
    )
    int answerBelongsToQuestionInt(@Param("answerId") long answerId,
                                   @Param("questionId") long questionId);

    default boolean answerBelongsToQuestion(long answerId, long questionId) {
        return answerBelongsToQuestionInt(answerId, questionId) == 1;
    }

    // ---- 2) UPDATE nhánh upsert (NULL-safe cho cycle_id) ----
    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query(
        value = """
            UPDATE dbo.UserAnswers
            SET answer_id = :answerId,
                created_at = SYSDATETIME()   -- hoặc GETDATE() cũng được
            WHERE user_id = :userId
            AND question_id = :questionId
            AND ISNULL(cycle_id, -1) = ISNULL(:cycleId, -1)
            """,
        nativeQuery = true
    )
    int updateForUpsert(@Param("userId") long userId,
                        @Param("questionId") long questionId,
                        @Param("answerId") long answerId,
                        @Param("cycleId") Long cycleId);

    // ---- 3) INSERT nhánh upsert ----
    @Modifying
    @Query(
        value = """
            INSERT INTO dbo.UserAnswers(user_id, question_id, answer_id, cycle_id)
            VALUES (:userId, :questionId, :answerId, :cycleId)
            """,
        nativeQuery = true
    )
    int insertForUpsert(@Param("userId") long userId,
                        @Param("questionId") long questionId,
                        @Param("answerId") long answerId,
                        @Param("cycleId") Long cycleId);

    // ---- 4) API upsert giống pseudo-code bạn đưa ----
    @Transactional
    default String upsertFromNext(long userId, long questionId, long answerId, Long cycleId) {
        int rows = updateForUpsert(userId, questionId, answerId, cycleId);
        if (rows > 0) return "updated";

        insertForUpsert(userId, questionId, answerId, cycleId);
        return "created";
    }
}