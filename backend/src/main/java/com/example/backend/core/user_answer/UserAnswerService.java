package com.example.backend.core.user_answer;

import java.util.Map;
import org.springframework.stereotype.Service;

@Service
public class UserAnswerService {

    private final UserAnswerRepository userAnswerDao;

    public UserAnswerService(UserAnswerRepository userAnswerDao) {
        this.userAnswerDao = userAnswerDao;
    }

    /** Handler cho nút Next */
    public Map<String, Object> nextSubmit(SubmitAnswerRequest req) {
        // Validate cặp question/answer
        if (!userAnswerDao.answerBelongsToQuestion(req.getAnswerId(), req.getQuestionId())) {
            throw new IllegalArgumentException("answer_id không thuộc question_id tương ứng.");
        }
        String status = userAnswerDao.upsertFromNext(
                req.getUserId(),
                req.getQuestionId(),
                req.getAnswerId(),
                req.getCycleId()
        );
        return Map.of("status", status);
    }
}