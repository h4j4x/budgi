package com.spike.budgi.domain.repo;

import com.spike.budgi.domain.jpa.JpaTransaction;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.Transaction;
import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.util.Optional;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TransactionRepo extends CrudRepository<JpaTransaction, Long> {
    Optional<JpaTransaction> findByUserAndCode(@NotNull JpaUser user, @NotNull String code);

    @Query("SELECT dateTime FROM JpaTransaction" +
        " WHERE user = :user AND dateTime < :to" +
        " ORDER BY dateTime DESC LIMIT 1")
    Optional<OffsetDateTime> findPreviousDateTimeTo(@NotNull JpaUser user, @NotNull OffsetDateTime to);

    Optional<JpaTransaction> findByParent(@NotNull Transaction parent);
}
