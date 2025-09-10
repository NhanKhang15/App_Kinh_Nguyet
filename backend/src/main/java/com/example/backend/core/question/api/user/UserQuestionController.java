package com.example.backend.core.question.api.user;

import java.util.Map;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.backend.core.question.Question;
import com.example.backend.core.question.QuestionRepository;

@RestController
@RequestMapping("/api/questions")
@CrossOrigin(origins = "*")
public class UserQuestionController {

    private final QuestionRepository repo;

    public UserQuestionController(QuestionRepository repo) {
        this.repo = repo;
    }

    /** List theo bộ (giữ nguyên) */
    @GetMapping("/{setId}")
    public Page<Question> listBySet(
            @PathVariable Long setId,
            @RequestParam(value = "active", required = false) Boolean active,
            @PageableDefault(size = 50, sort = "orderInSet", direction = Sort.Direction.ASC)
            Pageable pageable
    ) {
        boolean onlyActive = (active == null) ? true : active;
        return repo.findByQuestionSetIdAndIsActive(setId, onlyActive, pageable);
    }

    /** Lấy câu thứ N (1-based) trong bộ theo thứ tự orderInSet + active */
    @GetMapping("/{setId}/{ordinal}")
    public ResponseEntity<?> getByOrdinal(
            @PathVariable Long setId,
            @PathVariable int ordinal,
            @RequestParam(value = "active", required = false) Boolean active
    ) {
        if (ordinal < 1) {
            return ResponseEntity.badRequest().body(Map.of(
                    "error", "ordinal must be >= 1"
            ));
        }
        boolean onlyActive = (active == null) ? true : active;

        // page = ordinal-1, size = 1, sort theo orderInSet ASC
        PageRequest pr = PageRequest.of(
                ordinal - 1,
                1,
                Sort.by(Sort.Direction.ASC, "orderInSet")
        );

        Page<Question> page = repo.findByQuestionSetIdAndIsActive(setId, onlyActive, pr);
        long total = page.getTotalElements();
        if (page.isEmpty() || ordinal > total) {
            return ResponseEntity.status(404).body(Map.of(
                    "error", "Question not found at this ordinal",
                    "setId", setId,
                    "ordinal", ordinal,
                    "total", total
            ));
        }

        Question q = page.getContent().get(0);

        // Gói meta để FE biết tổng + ordinal hiện tại
        return ResponseEntity.ok(Map.of(
                "setId", setId,
                "ordinal", ordinal,
                "total", total,
                "question", q
        ));
    }
}
