package com.example.backend.core.answer;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AnswerService {
    private final AnswerRepository repo;

    public AnswerService(AnswerRepository repo) { this.repo = repo; }

    @Transactional
    public Answer create(AnswerCreateDto dto) {
        Answer a = new Answer();
        a.setQuestionId(dto.questionId);
        a.setLabel(dto.label != null ? dto.label : "A");
        a.setText(dto.text);
        a.setHint(dto.hint);
        // nếu không gửi order → đặt cuối danh sách (max+10)
        if (dto.orderInQuestion == null) {
            Integer last = repo.findByQuestionId(dto.questionId,
                    org.springframework.data.domain.PageRequest.of(0,1,
                      org.springframework.data.domain.Sort.by("orderInQuestion").descending()))
                    .stream().findFirst().map(Answer::getOrderInQuestion).orElse(0);
            a.setOrderInQuestion(last == null ? 10 : last + 10);
        } else {
            a.setOrderInQuestion(dto.orderInQuestion);
        }
        return repo.save(a);
    }

    @Transactional
    public Answer patch(Long id, AnswerUpdateDto dto) {
        Answer a = repo.findById(id).orElseThrow(() -> new RuntimeException("Answer not found"));
        if (dto.label != null) a.setLabel(dto.label);
        if (dto.text != null)  a.setText(dto.text);
        if (dto.hint != null)  a.setHint(dto.hint);
        if (dto.orderInQuestion != null) a.setOrderInQuestion(dto.orderInQuestion);
        return repo.save(a);
    }
}
