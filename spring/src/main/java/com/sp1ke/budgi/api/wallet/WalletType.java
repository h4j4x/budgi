package com.sp1ke.budgi.api.wallet;

import com.fasterxml.jackson.annotation.JsonProperty;

public enum WalletType {
    @JsonProperty("cash")
    CASH,
    @JsonProperty("creditCard")
    CREDIT_CARD,
    @JsonProperty("debitCard")
    DEBIT_CARD
}
