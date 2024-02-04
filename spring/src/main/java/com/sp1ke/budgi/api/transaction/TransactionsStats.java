package com.sp1ke.budgi.api.transaction;

import com.sp1ke.budgi.api.category.ApiCategory;
import com.sp1ke.budgi.api.wallet.ApiWallet;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Builder
@Getter
@Setter
public class TransactionsStats {
    private LocalDate from;

    private LocalDate to;

    private BigDecimal income;

    private Map<ApiCategory, BigDecimal> budget;

    private Map<ApiCategory, BigDecimal> expense;

    private Map<ApiWallet, BigDecimal> balance;
}
