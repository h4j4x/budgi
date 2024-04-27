package com.spike.budgi.domain.jpa;

import com.spike.budgi.domain.converter.CurrencyConverter;
import com.spike.budgi.domain.model.Account;
import com.spike.budgi.domain.model.AccountType;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Currency;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@Getter
@NoArgsConstructor
@Setter
@SuperBuilder(toBuilder = true)
@Table(name = "accounts", indexes = {
    @Index(name = "accounts_user_id_code_UNQ", columnList = "user_id, code", unique = true),
})
public class JpaAccount extends JpaBase implements Account {
    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private JpaUser user;

    @Column(length = 100, nullable = false)
    @NotBlank(message = "Account label is required.")
    @Size(max = 100, min = 3, message = "Account label must have between 3 and 100 characters length.")
    private String label;

    @Column(length = 300)
    @Size(max = 300, message = "Account description must have 100 characters length maximum.")
    private String description;

    @Column(length = 50, name = "account_type", nullable = false)
    @Enumerated(EnumType.STRING)
    @NotNull(message = "Account type is required.")
    private AccountType accountType;

    @Column(length = 3, nullable = false)
    @NotNull(message = "Account currency is required.")
    @Convert(converter = CurrencyConverter.class)
    private Currency currency;

    @PositiveOrZero(message = "Account quota amount must be positive or zero.")
    @Column(nullable = false, precision = 38, scale = 2)
    private BigDecimal quota;

    @PositiveOrZero(message = "Account to pay amount must be positive or zero.")
    @Column(name = "to_pay", nullable = false, precision = 38, scale = 2)
    private BigDecimal toPay;

    @Column(name = "payment_day", columnDefinition = "smallint")
    private Short paymentDay;

    @Override
    @PrePersist
    protected void prePersist() {
        super.prePersist();
        quota = quota.setScale(2, RoundingMode.HALF_UP);
        toPay = toPay.setScale(2, RoundingMode.HALF_UP);
    }
}
