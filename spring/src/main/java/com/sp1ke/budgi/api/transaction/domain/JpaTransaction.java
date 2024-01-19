package com.sp1ke.budgi.api.transaction.domain;

import com.sp1ke.budgi.api.data.JpaUserBase;
import com.sp1ke.budgi.api.data.MoneyType;
import com.sp1ke.budgi.api.transaction.TransactionType;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.OffsetDateTime;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;
import org.hibernate.annotations.CompositeType;
import org.joda.money.Money;

@Entity
@Table(name = "transactions", indexes = {
    @Index(name = "transactions_user_id_code_UNQ", columnList = "userId, code", unique = true),
    @Index(name = "transactions_category_id_IDX", columnList = "categoryId"),
    @Index(name = "transactions_wallet_id_IDX", columnList = "walletId"),
    @Index(name = "transactions_transaction_type_IDX", columnList = "transactionType"),
    @Index(name = "transactions_date_time_IDX", columnList = "dateTime"),
})
@SuperBuilder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class JpaTransaction extends JpaUserBase {
    @Column(name = "category_id", nullable = false)
    private Long categoryId;

    @Column(name = "wallet_id", nullable = false)
    private Long walletId;

    @Enumerated(EnumType.STRING)
    @NotNull(message = "Transaction type is required")
    @Column(name = "transaction_type", length = 50, nullable = false)
    private TransactionType transactionType;

    @AttributeOverride(name = "amount", column = @Column(name = "amount"))
    @AttributeOverride(name = "currency", column = @Column(name = "currency"))
    @CompositeType(MoneyType.class)
    private Money amount;

    @Size(min = 2, max = 100, message = "Valid transaction description is required (2 to 255 characters)")
    @NotNull(message = "Valid transaction description is required (2 to 255 characters)")
    @Column(nullable = false)
    private String description;

    @Column(name = "date_time", nullable = false)
    private OffsetDateTime dateTime;
}
