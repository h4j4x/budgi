package com.sp1ke.budgi.api.common;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Currency;

public record SavedTransactionEvent(Long userId, String walletCode, Currency currency,
                                    OffsetDateTime dateTime,
                                    BigDecimal previousAmount, BigDecimal newAmount) {
}
