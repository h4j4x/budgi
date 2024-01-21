package com.sp1ke.budgi.api.transaction;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Nullable;
import com.fasterxml.jackson.annotation.JsonProperty;

public enum TransactionType {
    @JsonProperty("income")
    INCOME,
    @JsonProperty("incomeTransfer")
    INCOME_TRANSFER,
    @JsonProperty("expense")
    EXPENSE,
    @JsonProperty("expenseTransfer")
    EXPENSE_TRANSFER;

    @Nullable
    public static TransactionType parse(@NotNull String value) {
        for (var transactionType : values()) {
            if (transactionType.name().equalsIgnoreCase(value.trim())) {
                return transactionType;
            }
        }
        return null;
    }
}
