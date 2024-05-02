package com.spike.budgi.domain.jpa;

import com.spike.budgi.domain.converter.CurrencyConverter;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
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
@Table(name = "categories_expenses", indexes = {
    @Index(name = "categories_expenses_period_IDX", columnList = "fromDateTime, toDateTime"),
})
public class JpaCategoryExpense extends JpaBase {
    @ManyToOne(optional = false)
    @NotNull(message = "User is required.")
    @JoinColumn(name = "user_id", nullable = false)
    private JpaUser user;

    @ManyToOne(optional = false)
    @NotNull(message = "Category is required.")
    @JoinColumn(name = "category_id", nullable = false)
    private JpaCategory category;

    @Column(length = 3, nullable = false)
    @NotNull(message = "Currency is required.")
    @Convert(converter = CurrencyConverter.class)
    private Currency currency;

    @NotNull(message = "Amount is required.")
    @Column(nullable = false, precision = 38, scale = 2)
    private BigDecimal amount;

    @Column(name = "from_date_time")
    private OffsetDateTime fromDateTime;

    @Column(name = "to_date_time")
    private OffsetDateTime toDateTime;
}
