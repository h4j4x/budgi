package com.sp1ke.budgi.api.category.repo;

import com.sp1ke.budgi.api.category.domain.JpaCategoryBudget;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CategoryBudgetRepo extends CrudRepository<JpaCategoryBudget, Long> {
    Page<JpaCategoryBudget> findAllByUserIdAndFromDateAndToDate(Long userId,
                                                                LocalDate fromDate, LocalDate toDate,
                                                                Pageable pageable);

    Long countByUserIdAndFromDateAndToDate(Long userId, LocalDate fromDate, LocalDate toDate);

    Optional<JpaCategoryBudget> findByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCodeIn(Long userId, String[] codes);

    @Query("SELECT budget FROM JpaCategoryBudget budget" +
        " WHERE userId = :userId" +
        " AND fromDate >= :from AND toDate < :to")
    List<JpaCategoryBudget> findAllByUserIdAndDatesBetween(Long userId, LocalDate from, LocalDate to);
}
