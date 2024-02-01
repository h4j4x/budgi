package com.sp1ke.budgi.api.data;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import jakarta.persistence.PrePersist;
import jakarta.validation.constraints.PositiveOrZero;
import java.math.BigDecimal;
import java.util.Currency;
import javax.annotation.OverridingMethodsMustInvokeSuper;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

@MappedSuperclass
@SuperBuilder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class JpaUserAmountBase extends JpaUserBase {
    @Column(length = 3, nullable = false)
    private Currency currency;

    @PositiveOrZero(message = "Positive or zero amount is required")
    @Column(nullable = false, precision = 38, scale = 2)
    private BigDecimal amount;

    @Override
    @PrePersist
    @OverridingMethodsMustInvokeSuper
    protected void prePersist() {
        super.prePersist();
        if (currency == null) {
            currency = Currency.getInstance("USD");
        }
    }
}
