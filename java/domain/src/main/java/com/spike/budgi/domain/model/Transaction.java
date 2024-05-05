package com.spike.budgi.domain.model;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Currency;
import java.util.Set;

public interface Transaction extends Base, Validatable {
    User getUser();

    Transaction getTransfer();

    Account getAccount();

    Set<Category> getCategories();

    String getDescription();

    Currency getCurrency();

    BigDecimal getAmount();

    BigDecimal getAccountBalance();

    OffsetDateTime getDateTime();

    DatePeriod getDatePeriod();
}
