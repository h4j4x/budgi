package com.sp1ke.budgi.api.transaction.repo;

import com.sp1ke.budgi.api.transaction.domain.JpaTransaction;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TransactionRepo extends CrudRepository<JpaTransaction, Long> {
    Page<JpaTransaction> findAllByUserId(Long userId, Pageable pageable);

    Optional<JpaTransaction> findByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCodeIn(Long userId, String[] codes);
}
