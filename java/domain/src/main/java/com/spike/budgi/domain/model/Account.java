package com.spike.budgi.domain.model;

import java.math.BigDecimal;
import java.util.Currency;

public interface Account extends Base, Validatable {
    User getUser();

    String getLabel();

    String getDescription();

    AccountType getAccountType();

    Currency getCurrency();

    BigDecimal getQuota();

    BigDecimal getToPay();

    Short getPaymentDay();
}
