package com.sp1ke.budgi.api.wallet;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.annotation.Nullable;
import jakarta.validation.constraints.NotNull;

public enum WalletType {
    @JsonProperty("cash")
    CASH,
    @JsonProperty("creditCard")
    CREDIT_CARD,
    @JsonProperty("debitCard")
    DEBIT_CARD;

    @Nullable
    public static WalletType parse(@NotNull String value) {
        for (var walletType : values()) {
            if (walletType.name().equalsIgnoreCase(value.trim())) {
                return walletType;
            }
        }
        return null;
    }
}
