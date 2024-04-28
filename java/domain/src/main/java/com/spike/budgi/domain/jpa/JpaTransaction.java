package com.spike.budgi.domain.jpa;

import com.spike.budgi.domain.converter.CurrencyConverter;
import com.spike.budgi.domain.model.AccountType;
import com.spike.budgi.domain.model.Category;
import com.spike.budgi.domain.model.Transaction;
import com.spike.budgi.util.DateTimeUtil;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.OffsetDateTime;
import java.util.Currency;
import java.util.Set;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@Getter
@NoArgsConstructor
@Setter
@SuperBuilder(toBuilder = true)
@Table(name = "transactions", indexes = {
    @Index(name = "transactions_user_id_code_UNQ", columnList = "user_id, code", unique = true),
})
public class JpaTransaction extends JpaBase implements Transaction {
    @ManyToOne(optional = false)
    @NotNull(message = "Transaction user is required.")
    @JoinColumn(name = "user_id", nullable = false)
    private JpaUser user;

    @OneToOne
    @JoinColumn(name = "parent_id")
    private JpaTransaction parent;

    @OneToOne
    @JoinColumn(name = "transfer_id")
    private JpaTransaction transfer;

    @ManyToOne(optional = false)
    @NotNull(message = "Transaction account is required.")
    @JoinColumn(name = "account_id", nullable = false)
    private JpaAccount account;

    @ManyToMany(targetEntity = JpaCategory.class)
    @JoinTable(name = "categories_transactions",
        joinColumns = @JoinColumn(name = "transaction_id", referencedColumnName = "id"),
        inverseJoinColumns = @JoinColumn(name = "category_id", referencedColumnName = "id")
    )
    private Set<Category> categories;

    @Column(length = 300)
    @Size(max = 300, message = "Transaction description must have 100 characters length maximum.")
    private String description;

    @Column(length = 3, nullable = false)
    @NotNull(message = "Transaction currency is required.")
    @Convert(converter = CurrencyConverter.class)
    private Currency currency;

    @NotNull(message = "Transaction amount is required.")
    @Column(nullable = false, precision = 38, scale = 2)
    private BigDecimal amount;

    @Column(name = "due_at")
    private OffsetDateTime dueAt;

    @Column(name = "completed_at")
    private OffsetDateTime completedAt;

    @Override
    @PrePersist
    protected void prePersist() {
        super.prePersist();
        amount = amount.setScale(2, RoundingMode.HALF_UP);
        if (AccountType.CREDIT.equals(account.getAccountType()) && dueAt == null) {
            dueAt = DateTimeUtil.nextDayOfMonth(account.getPaymentDay());
        }
    }
}
