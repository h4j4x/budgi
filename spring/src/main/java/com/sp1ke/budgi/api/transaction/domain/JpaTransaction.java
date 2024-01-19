package com.sp1ke.budgi.api.transaction.domain;

import com.sp1ke.budgi.api.transaction.TransactionType;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.OffsetDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.joda.money.Money;

@Entity
@Table(name = "transactions", indexes = {
    @Index(name = "transactions_user_id_code_UNQ", columnList = "userId, code", unique = true),
    @Index(name = "transactions_category_id_IDX", columnList = "categoryId"),
    @Index(name = "transactions_wallet_id_IDX", columnList = "walletId"),
    @Index(name = "transactions_transaction_type_IDX", columnList = "transactionType"),
    @Index(name = "transactions_date_time_IDX", columnList = "dateTime"),
})
@Builder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class JpaTransaction {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Size(min = 2, max = 100, message = "Valid transaction code is required (2 to 100 characters)")
    @NotNull(message = "Valid transaction code is required (2 to 100 characters)")
    @Column(length = 100, nullable = false)
    private String code;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "category_id", nullable = false)
    private Long categoryId;

    @Column(name = "wallet_id", nullable = false)
    private Long walletId;

    @Enumerated(EnumType.STRING)
    @NotNull(message = "Transaction type is required")
    @Column(name = "transaction_type", length = 50, nullable = false)
    private TransactionType transactionType;

    @AttributeOverrides({
        @AttributeOverride(name = "amount", column = @Column(name = "amount")),
        @AttributeOverride(name = "currency", column = @Column(name = "currency"))
    })
    @Embedded
    private Money amount;

    @Size(min = 2, max = 100, message = "Valid transaction description is required (2 to 255 characters)")
    @NotNull(message = "Valid transaction description is required (2 to 255 characters)")
    @Column(nullable = false)
    private String description;

    @Column(name = "date_time", nullable = false)
    private OffsetDateTime dateTime;

    @CreationTimestamp
    @Column(updatable = false, name = "created_at")
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;
}
