package com.sp1ke.budgi.api.transaction;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.annotation.Nullable;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
@Getter
public enum TransactionType {
    @JsonProperty("income")
    INCOME(false),
    @JsonProperty("incomeTransfer")
    INCOME_TRANSFER(false),
    @JsonProperty("expense")
    EXPENSE(true),
    @JsonProperty("expenseTransfer")
    EXPENSE_TRANSFER(true);

    private final boolean isExpense;

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
