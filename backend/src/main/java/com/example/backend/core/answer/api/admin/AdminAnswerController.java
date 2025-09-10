package com.example.backend.core.answer.api.admin;

import java.util.List;
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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.backend.core.answer.Answer;
import com.example.backend.core.answer.AnswerCreateDto;
import com.example.backend.core.answer.AnswerRepository;
import com.example.backend.core.answer.AnswerService;
import com.example.backend.core.answer.AnswerUpdateDto;

import jakarta.validation.Valid;


@RestController
@RequestMapping("/api/answers")
public class AdminAnswerController {
    private final AnswerRepository repo;
    private final AnswerService svc;

    public AdminAnswerController(AnswerRepository repo, AnswerService svc) {
        this.repo = repo; this.svc = svc;
    }

    // (1) List đáp án theo question_id (phân trang + sort theo order)
    // GET /api/answers?questionId=123&page=0&size=50&sort=orderInQuestion,asc
    @GetMapping
    public Page<Answer> listByQuestion(
            @RequestParam Long questionId,
            @PageableDefault(size = 50, sort = "orderInQuestion", direction = Sort.Direction.ASC)
            Pageable pageable) {
        return repo.findByQuestionId(questionId, pageable);
    }

    // (2) Lấy chi tiết 1 đáp án
    // GET /api/answers/5
    @GetMapping("/{id}")
    public ResponseEntity<Answer> getOne(@PathVariable Long id) {
        return repo.findById(id).map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // (3) Tạo đáp án mới
    // POST /api/answers
    @PostMapping
    public ResponseEntity<Answer> create(@Valid @RequestBody AnswerCreateDto dto) {
        Answer saved = svc.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    // (4) Sửa một phần (PATCH)
    // PATCH /api/answers/5
    @PatchMapping("/{id}")
    public ResponseEntity<Answer> patch(@PathVariable Long id, @RequestBody AnswerUpdateDto dto) {
        Answer saved = svc.patch(id, dto);
        return ResponseEntity.ok(saved);
    }

    // (5) Xoá đáp án
    // DELETE /api/answers/5
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!repo.existsById(id)) return ResponseEntity.notFound().build();
        repo.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    // (6) Bulk reorder: [{ "id":1, "orderInQuestion":10 }, ...]
    // PATCH /api/answers/reorder
    @PatchMapping("/reorder")
    public ResponseEntity<?> bulkReorder(@RequestBody List<Map<String, Object>> payload) {
        for (var item : payload) {
            Long id = Long.valueOf(item.get("id").toString());
            Integer ord = Integer.valueOf(item.get("orderInQuestion").toString());
            repo.findById(id).ifPresent(a -> { a.setOrderInQuestion(ord); repo.save(a); });
        }
        return ResponseEntity.ok(Map.of("updated", payload.size()));
    }
}
