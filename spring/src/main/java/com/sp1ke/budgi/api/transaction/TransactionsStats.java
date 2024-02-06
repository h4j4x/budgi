package com.sp1ke.budgi.api.transaction;

import com.sp1ke.budgi.api.category.ApiCategory;
import com.sp1ke.budgi.api.wallet.ApiWallet;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Builder
@Getter
@Setter
public class TransactionsStats implements Serializable {
    private LocalDate from;

    private LocalDate to;

    private BigDecimal income;

    private Map<String, BigDecimal> categoryBudget;

    private Map<String, BigDecimal> categoryExpense;

    private Map<String, BigDecimal> walletBalance;

    private Map<String, ApiCategory> categories;

    private Map<String, ApiWallet> wallets;
}
