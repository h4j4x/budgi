package com.sp1ke.budgi.api.transaction;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.annotation.Nullable;
import jakarta.validation.constraints.NotNull;

public enum TransactionStatus {
    @JsonProperty("pending")
    PENDING,
    @JsonProperty("completed")
    COMPLETED;

    @Nullable
    public static TransactionStatus parse(@NotNull String value) {
        for (var transactionType : values()) {
            if (transactionType.name().equalsIgnoreCase(value.trim())) {
                return transactionType;
            }
        }
        return null;
    }
}
