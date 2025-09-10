package com.example.backend.core.question.api.admin;

import java.util.Map;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.backend.core.question.Question;
import com.example.backend.core.question.QuestionRepository;
import com.example.backend.core.question.QuestionService;


@RestController
@RequestMapping("/api/questions")
public class AdminQuestionController {
    private final QuestionRepository repo;
    private final QuestionService questionService;

    public AdminQuestionController(QuestionRepository repo, QuestionService questionService) {
        this.repo = repo;
        this.questionService = questionService;
    }

    // GET /api/questions?q=...&page=0&size=20&sort=questionSetId,asc&sort=orderInSet,asc
    @GetMapping
    public Page<Question> list(
        @RequestParam(value = "q", required = false) String q,
        @PageableDefault(size = 20, sort = {"questionSetId", "orderInSet"}, direction = Sort.Direction.ASC)
        Pageable pageable
    ) {
        if (q != null && !q.isBlank()) {
            return repo.findByQuestionTextContainingIgnoreCase(q.trim(), pageable);
        }
        return repo.findAll(pageable);
    }

    // PATCH /api/questions/{id}
    // body: { "text": "...", "orderInSet": 10, "isActive": true }
    @PatchMapping("/{id}")
    public ResponseEntity<Question> patch(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {

        Question q = repo.findById(id)
                .orElseThrow(() -> new org.springframework.web.server.ResponseStatusException(HttpStatus.NOT_FOUND, "Question not found"));

        if (body.containsKey("text")) {
            String text = String.valueOf(body.get("text")).trim();
            if (text.isEmpty()) throw new org.springframework.web.server.ResponseStatusException(HttpStatus.BAD_REQUEST, "text cannot be empty");
            q.setQuestionText(text);
        }
        if (body.containsKey("orderInSet")) {
            q.setOrderInSet(Integer.valueOf(String.valueOf(body.get("orderInSet"))));
        }
        if (body.containsKey("isActive")) {
            q.setIsActive(Boolean.valueOf(String.valueOf(body.get("isActive"))));
        }
        return ResponseEntity.ok(repo.save(q));
    }

    // DELETE /api/questions/{id}  (hard delete)
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!repo.existsById(id)) return ResponseEntity.notFound().build();
        repo.deleteById(id);   // ⚠️ nếu có bảng Answers, hãy dùng FK ON DELETE CASCADE hoặc xóa con trước
        return ResponseEntity.noContent().build();
    }

    // PATCH /api/questions/{id}/status
    @PatchMapping("/{id}/status")
    public ResponseEntity<Question> updateStatus(
            @PathVariable Long id,
            @RequestParam boolean active) {
        return repo.findById(id)
                .map(q -> {
                    q.setIsActive(active);
                    repo.save(q);
                    return ResponseEntity.ok(q);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // PATCH /api/questions/{id}/move
    @PatchMapping("/{id}/move-to")
    public Question moveTo(@PathVariable Long id, @RequestBody MoveToDto dto) {
      return questionService.moveTo(id, dto);
    }

    @org.springframework.web.bind.annotation.PostMapping
    public ResponseEntity<Question> create(
            @org.springframework.web.bind.annotation.RequestBody CreateQuestionDto dto,
            org.springframework.web.util.UriComponentsBuilder ucb) {

        try {
            Question saved = questionService.create(dto);
            java.net.URI location = ucb.path("/api/questions/{id}")
                    .buildAndExpand(saved.getId()).toUri();
            return ResponseEntity.created(location).body(saved);
        } catch (IllegalArgumentException ex) {
            throw new org.springframework.web.server.ResponseStatusException(HttpStatus.BAD_REQUEST, ex.getMessage());
        }
    }

    public record CreateQuestionDto(
        String questionText,
        Integer questionSetId,
        Integer orderInSet,
        Boolean isActive,
        String typeId // "single" | "multiple" | "text" (case-insensitive)
    ) {}
}
