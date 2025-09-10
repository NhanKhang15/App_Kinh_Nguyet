package com.example.backend.core.question;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.backend.core.question.api.admin.AdminQuestionController;
import com.example.backend.core.question.api.admin.MoveToDto;
;

@Service
public class QuestionService {
  private final QuestionRepository repo;
  private final JdbcTemplate jdbc;

  public QuestionService(QuestionRepository repo, JdbcTemplate jdbc) {
    this.repo = repo; this.jdbc = jdbc;
  }

  @Transactional
  public Question create(AdminQuestionController.CreateQuestionDto dto) {
    // validate cơ bản
    if (dto.questionText() == null || dto.questionText().trim().isEmpty())
      throw new IllegalArgumentException("questionText cannot be empty");
    if (dto.questionSetId() == null)
      throw new IllegalArgumentException("questionSetId is required");

    // chuẩn hoá type
    String type = normalizeType(dto.typeId());

    Integer setId = dto.questionSetId();

    // tính order
    Integer finalOrder;
    if (dto.orderInSet() == null) {
      Integer maxOrder = repo.findMaxOrderInSet(setId);
      finalOrder = (maxOrder == null ? 0 : maxOrder) + 1; // append
    } else {
      finalOrder = dto.orderInSet();
      // dịch các item có order >= finalOrder xuống 1 để chèn
      jdbc.update("""
          UPDATE dbo.Questions
             SET order_in_set = order_in_set + 1
           WHERE question_set_id = ? AND order_in_set >= ?
      """, setId, finalOrder);
    }

    // tạo entity
    Question q = new Question();
    q.setQuestionSetId(setId);
    q.setQuestionText(dto.questionText().trim());
    q.setType(type);
    q.setOrderInSet(finalOrder);
    q.setIsActive(dto.isActive() == null ? Boolean.TRUE : dto.isActive());

    return repo.save(q);
  }

  @Transactional
  public Question moveTo(Long id, MoveToDto dto) {
      if (dto.targetIndex == null || dto.targetIndex < 1)
          throw new IllegalArgumentException("targetIndex must be >= 1");
  
      Question q = repo.findById(id)
          .orElseThrow(() -> new IllegalArgumentException("Question not found"));
  
      long setId = q.getQuestionSetId();
      int cur  = q.getOrderInSet();
      int tgt  = dto.targetIndex;
  
      if (cur == tgt) return q;
  
      // 1) GHIM TẠM: đẩy item ra xa để không va unique (âm là an toàn vì các order khác dương)
      jdbc.update("""
          UPDATE dbo.Questions
             SET order_in_set = -order_in_set
           WHERE id = ?
      """, id);
  
      if (tgt < cur) {
          // 2) DỜI DẢI LÊN TRÊN: [tgt .. cur-1] +1
          jdbc.update("""
              UPDATE dbo.Questions
                 SET order_in_set = order_in_set + 1
               WHERE question_set_id = ? AND order_in_set BETWEEN ? AND ?
          """, setId, tgt, cur - 1);
      } else {
          // 2) DỜI DẢI XUỐNG DƯỚI: [cur+1 .. tgt] -1
          jdbc.update("""
              UPDATE dbo.Questions
                 SET order_in_set = order_in_set - 1
               WHERE question_set_id = ? AND order_in_set BETWEEN ? AND ?
          """, setId, cur + 1, tgt);
      }
  
      // 3) ĐẶT VỀ ĐÍCH
      jdbc.update("""
          UPDATE dbo.Questions
             SET order_in_set = ?
           WHERE id = ?
      """, tgt, id);
  
      // cập nhật entity trả về (optional)
      q.setOrderInSet(tgt);
      return q;
  }

  private String normalizeType(String typeId) {
    if (typeId == null) throw new IllegalArgumentException("typeId is required");
    String t = typeId.trim().toLowerCase();
    return switch (t) {
      case "single", "single_choice", "singlechoice" -> "single";
      case "multiple", "multi", "multi_choice", "multichoice" -> "multiple";
      case "text", "free_text", "freetext" -> "text";
      default -> throw new IllegalArgumentException("Invalid typeId. Use: single | multiple | text");
    };
  }
  
}
