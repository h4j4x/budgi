package com.sp1ke.budgi.api.transaction;

import java.time.OffsetDateTime;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import org.joda.money.Money;

@Builder
@Getter
@Setter
public class ApiTransaction {
    private String code;

    private String categoryCode;

    private String walletCode;

    private TransactionType transactionType;

    private Money amount;

    private String description;

    private OffsetDateTime dateTime;
}
