package com.sp1ke.budgi.api.wallet;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Currency;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Builder
@Getter
@Setter
public class ApiWalletBalance {
    private String code;

    private String walletCode;

    private ApiWallet wallet;

    private Currency currency;

    private BigDecimal amount;

    private LocalDate fromDate;

    private LocalDate toDate;
}
