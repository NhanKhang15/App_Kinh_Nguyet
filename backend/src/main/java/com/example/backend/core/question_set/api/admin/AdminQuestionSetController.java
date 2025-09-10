package com.example.backend.core.question_set.api.admin;


import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.backend.core.question_set.QuestionSet;
import com.example.backend.core.question_set.QuestionSetRepository;
import com.example.backend.core.question.Question;
import com.example.backend.core.question.QuestionRepository;


@RestController
@RequestMapping("/api/question-sets")
public class AdminQuestionSetController {
    private final QuestionSetRepository setRepo;
    private final QuestionRepository qRepo;

    public AdminQuestionSetController(QuestionSetRepository setRepo, QuestionRepository qRepo) {
        this.setRepo = setRepo;
        this.qRepo = qRepo;
    }

    // (A) List tất cả bộ câu hỏi (có search theo name + filter active)
    // GET /api/question-sets?name=toan&active=true&page=0&size=10&sort=updatedAt,desc
    @GetMapping
    public Page<QuestionSet> listSets(
            @RequestParam(required = false) String name,
            @RequestParam(required = false) Boolean active,
            @PageableDefault(size = 20, sort = "updatedAt", direction = Sort.Direction.DESC)
            Pageable pageable
    ) {
        if (name != null && !name.isBlank()) {
            return setRepo.findByNameContainingIgnoreCase(name.trim(), pageable);
        }
        if (active != null) {
            return setRepo.findByIsActive(active, pageable);
        }
        return setRepo.findAll(pageable);
    }

    // (B) Lấy 1 bộ theo id
    // GET /api/question-sets/3
    @GetMapping("/{id}")
    public ResponseEntity<QuestionSet> getSet(@PathVariable Long id) {
        return setRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // (C) Lấy 1 bộ theo name (exact match)
    // GET /api/question-sets/by-name/Bo%20Cau%20Hoi%20YTe
    @GetMapping("/by-name/{name}")
    public ResponseEntity<QuestionSet> getSetByName(@PathVariable String name) {
        QuestionSet qs = setRepo.findByName(name);
        return qs != null ? ResponseEntity.ok(qs) : ResponseEntity.notFound().build();
    }

    // (D) Lấy danh sách câu hỏi thuộc 1 bộ (theo ID)
    // GET /api/question-sets/3/questions?active=true&page=0&size=20&sort=orderInSet,asc
    @GetMapping("/{id}/questions")
    public ResponseEntity<Page<Question>> getQuestionsOfSet(
            @PathVariable Long id,
            @RequestParam(required = false) Boolean active,
            @PageableDefault(size = 20, sort = "orderInSet", direction = Sort.Direction.ASC)
            Pageable pageable
    ) {
        if (!setRepo.existsById(id)) return ResponseEntity.notFound().build();
        Page<Question> page = (active == null)
                ? qRepo.findByQuestionSetId(id, pageable)
                : qRepo.findByQuestionSetIdAndIsActive(id, active, pageable);
        return ResponseEntity.ok(page);
    }

    // (E) Lấy danh sách câu hỏi thuộc 1 bộ theo TÊN bộ (tiện FE)
    // GET /api/question-sets/by-name/Bo%20Kham%20Tong%20Quat/questions?active=true&page=0&size=20
    @GetMapping("/by-name/{name}/questions")
    public ResponseEntity<Page<Question>> getQuestionsOfSetByName(
            @PathVariable String name,
            @RequestParam(required = false) Boolean active,
            @PageableDefault(size = 20, sort = "orderInSet", direction = Sort.Direction.ASC)
            Pageable pageable
    ) {
        QuestionSet qs = setRepo.findByName(name);
        if (qs == null) return ResponseEntity.notFound().build();
        Page<Question> page = (active == null)
                ? qRepo.findByQuestionSetId(qs.getId(), pageable)
                : qRepo.findByQuestionSetIdAndIsActive(qs.getId(), active, pageable);
        return ResponseEntity.ok(page);
    }
}
