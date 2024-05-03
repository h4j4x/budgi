package com.spike.budgi.domain.repo;

import com.spike.budgi.domain.jpa.JpaTransaction;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.Transaction;
import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TransactionRepo extends CrudRepository<JpaTransaction, Long> {
    Optional<JpaTransaction> findByUserAndCode(@NotNull JpaUser user, @NotNull String code);

    @Query("SELECT createdAt FROM JpaTransaction" +
        " WHERE user = :user AND createdAt < :to" +
        " ORDER BY createdAt DESC LIMIT 1")
    Optional<OffsetDateTime> findPreviousCreatedAt(@NotNull JpaUser user, @NotNull OffsetDateTime to);

    @Query("FROM JpaTransaction WHERE user = :user AND createdAt >= :from ORDER BY createdAt ASC")
    List<JpaTransaction> findByUserAndCreatedAtGreaterEqual(@NotNull JpaUser user, @NotNull OffsetDateTime from);

    Optional<JpaTransaction> findByParent(@NotNull Transaction parent);
}
