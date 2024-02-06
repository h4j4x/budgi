package com.sp1ke.budgi.api.transaction.repo;

import com.sp1ke.budgi.api.transaction.TransactionType;
import com.sp1ke.budgi.api.transaction.domain.JpaTransaction;
import com.sp1ke.budgi.api.transaction.model.IdAmount;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TransactionRepo extends CrudRepository<JpaTransaction, Long> {
    Page<JpaTransaction> findAllByUserId(Long userId, Pageable pageable);

    Optional<JpaTransaction> findByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCodeIn(Long userId, String[] codes);

    @Query("SELECT SUM(amount) FROM JpaTransaction" +
        " WHERE userId = :userId" +
        " AND dateTime >= :from AND dateTime < :to" +
        " AND transactionType = :transactionType")
    BigDecimal sumAmountByUserIdAndDatesAndTransactionType(Long userId,
                                                           OffsetDateTime from, OffsetDateTime to,
                                                           TransactionType transactionType);

    @Query("SELECT DISTINCT(categoryId) as id, SUM(amount) as amount FROM JpaTransaction" +
        " WHERE userId = :userId" +
        " AND dateTime >= :from AND dateTime < :to" +
        " AND transactionType = :transactionType" +
        " GROUP BY categoryId")
    List<IdAmount> sumByUserIdAndDatesAndTransactionTypeGroupByCategories(Long userId,
                                                                          OffsetDateTime from,
                                                                          OffsetDateTime to,
                                                                          TransactionType transactionType);
}
