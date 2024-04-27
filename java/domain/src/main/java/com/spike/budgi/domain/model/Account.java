package com.spike.budgi.domain.model;

import java.math.BigDecimal;

public interface Account extends Base {
    User getUser();

    String getLabel();

    String getDescription();

    AccountType getAccountType();

    BigDecimal getQuota();

    BigDecimal getToPay();

    Short getPaymentDay();
}
