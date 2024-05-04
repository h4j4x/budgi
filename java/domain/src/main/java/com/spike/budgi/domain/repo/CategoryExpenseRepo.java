package com.spike.budgi.domain.repo;

import com.spike.budgi.domain.jpa.JpaCategoryExpense;
import com.spike.budgi.domain.jpa.JpaUser;
import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.util.Optional;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CategoryExpenseRepo extends CrudRepository<JpaCategoryExpense, Long> {
    @Query("FROM JpaCategoryExpense" +
        " WHERE user = :user AND fromDateTime = :from AND toDateTime = :to")
    Optional<JpaCategoryExpense> findByUserAndPeriod(@NotNull JpaUser user,
                                                     @NotNull OffsetDateTime from, @NotNull OffsetDateTime to);
}
