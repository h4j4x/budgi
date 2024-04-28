package com.spike.budgi.domain.repo;

import com.spike.budgi.domain.jpa.JpaTransaction;
import com.spike.budgi.domain.jpa.JpaUser;
import jakarta.validation.constraints.NotNull;
import java.util.Optional;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TransactionRepo extends CrudRepository<JpaTransaction, Long> {
    Optional<JpaTransaction> findByUserAndCode(@NotNull JpaUser user, @NotNull String code);
}
