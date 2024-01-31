package com.sp1ke.budgi.api.category.repo;

import com.sp1ke.budgi.api.category.domain.JpaCategoryBudget;

import java.time.LocalDate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CategoryBudgetRepo extends CrudRepository<JpaCategoryBudget, Long> {
    Page<JpaCategoryBudget> findAllByUserIdAndFromDateAndToDate(Long userId,
                                                                LocalDate fromDate, LocalDate toDate,
                                                                Pageable pageable);

    void deleteByUserIdAndCategoryIdAndFromDateAndToDate(Long userId, Long categoryId,
                                                         LocalDate fromDate, LocalDate toDate);

    void deleteByUserIdAndFromDateAndToDateAndCategoryIdIn(Long userId,
                                                           LocalDate fromDate, LocalDate toDate,
                                                           Long[] categoriesIds);
}
