// package com.example.backend.core.user_answer;

// import org.springframework.dao.DataIntegrityViolationException;
// import org.springframework.http.HttpStatus;
// import org.springframework.stereotype.Service;
// import org.springframework.transaction.annotation.Transactional;
// import org.springframework.web.server.ResponseStatusException;

// @Service
// public class UserAnswerServiceImpl implements UserAnswerService {

//   private final UserAnswerRepository repo;

//   public UserAnswerServiceImpl(UserAnswerRepository repo) { this.repo = repo; }

//   @Override
//   @Transactional
//   public Map<String, Object> nextSubmit(SubmitAnswerRequest req) {
//     // ❗ chặn sớm: answer phải thuộc question
//     if (!repo.answerBelongsToQuestion(req.getAnswerId(), req.getQuestionId())) {
//       throw new ResponseStatusException(
//         HttpStatus.BAD_REQUEST, "answerId does not belong to questionId"
//       );
//     }
//     try {
//       String status = repo.upsertFromNext(
//         req.getUserId(), req.getQuestionId(), req.getAnswerId(), req.getCycleId()
//       );
//       return Map.of("status", status);
//     } catch (DataIntegrityViolationException e) {
//       throw new ResponseStatusException(
//         HttpStatus.BAD_REQUEST, "Data integrity violation: " + e.getMostSpecificCause().getMessage()
//       );
//     }
//   }
// }
