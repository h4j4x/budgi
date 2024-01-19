package com.sp1ke.budgi.api.transaction;

import com.fasterxml.jackson.annotation.JsonProperty;

public enum TransactionType {
    @JsonProperty("income")
    INCOME,
    @JsonProperty("incomeTransfer")
    INCOME_TRANSFER,
    @JsonProperty("expense")
    EXPENSE,
    @JsonProperty("expenseTransfer")
    EXPENSE_TRANSFER,
}
