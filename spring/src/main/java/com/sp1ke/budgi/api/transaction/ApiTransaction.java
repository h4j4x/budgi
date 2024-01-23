package com.sp1ke.budgi.api.transaction;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Currency;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Builder
@Getter
@Setter
public class ApiTransaction {
    private String code;

    private String categoryCode;

    private String walletCode;

    private TransactionType transactionType;

    private TransactionStatus transactionStatus;

    private Currency currency;

    private BigDecimal amount;

    private String description;

    private OffsetDateTime dateTime;
}
