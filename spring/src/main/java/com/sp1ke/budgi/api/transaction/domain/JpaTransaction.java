package com.sp1ke.budgi.api.transaction.domain;

import com.sp1ke.budgi.api.data.JpaUserAmountBase;
import com.sp1ke.budgi.api.transaction.TransactionStatus;
import com.sp1ke.budgi.api.transaction.TransactionType;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "transactions", indexes = {
    @Index(name = "transactions_user_id_code_UNQ", columnList = "userId, code", unique = true),
    @Index(name = "transactions_category_id_IDX", columnList = "categoryId"),
    @Index(name = "transactions_wallet_id_IDX", columnList = "walletId"),
    @Index(name = "transactions_transaction_type_IDX", columnList = "transactionType"),
    @Index(name = "transactions_transaction_status_IDX", columnList = "transactionStatus"),
    @Index(name = "transactions_date_time_IDX", columnList = "dateTime"),
})
@SuperBuilder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class JpaTransaction extends JpaUserAmountBase {
    @Column(name = "category_id", nullable = false)
    private Long categoryId;

    @Column(name = "wallet_id", nullable = false)
    private Long walletId;

    @Enumerated(EnumType.STRING)
    @NotNull(message = "Transaction type is required")
    @Column(name = "transaction_type", length = 50, nullable = false)
    private TransactionType transactionType;

    @Enumerated(EnumType.STRING)
    @Column(name = "transaction_status", length = 50, nullable = false)
    private TransactionStatus transactionStatus;

    @Size(min = 2, max = 100, message = "Valid transaction description is required (2 to 255 characters)")
    @NotNull(message = "Valid transaction description is required (2 to 255 characters)")
    @Column(nullable = false)
    private String description;

    @Column(name = "date_time", nullable = false)
    private OffsetDateTime dateTime;

    @Override
    @PrePersist
    protected void prePersist() {
        super.prePersist();
        if (transactionStatus == null) {
            transactionStatus = TransactionStatus.COMPLETED;
        }
        if (dateTime == null) {
            dateTime = OffsetDateTime.now();
        }
    }

    @NotNull
    public BigDecimal getSignedAmount() {
        var amount = getAmount();
        if (transactionType.isExpense()) {
            return amount.negate();
        }
        return amount;
    }
}
