package com.sp1ke.budgi.api.category.repo;

import com.sp1ke.budgi.api.category.domain.JpaCategoryBudget;
import java.time.LocalDate;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CategoryBudgetRepo extends CrudRepository<JpaCategoryBudget, Long> {
    Page<JpaCategoryBudget> findAllByUserIdAndFromDateAndToDate(Long userId,
                                                                LocalDate fromDate, LocalDate toDate,
                                                                Pageable pageable);

    Optional<JpaCategoryBudget> findByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCodeIn(Long userId, String[] codes);
}
