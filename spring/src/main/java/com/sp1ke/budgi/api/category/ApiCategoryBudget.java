package com.sp1ke.budgi.api.category;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Currency;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Builder
@Getter
@Setter
public class ApiCategoryBudget {
    private String categoryCode;

    private Currency currency;

    private BigDecimal amount;

    private LocalDate fromDate;

    private LocalDate toDate;
}
