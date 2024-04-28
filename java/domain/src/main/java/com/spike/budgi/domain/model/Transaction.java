package com.spike.budgi.domain.model;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Currency;
import java.util.List;

public interface Transaction extends Base, Validatable {
    User getUser();

    Transaction getParent();

    Transaction getTransfer();

    Account getAccount();

    List<Category> getCategories();

    String getDescription();

    Currency getCurrency();

    BigDecimal getAmount();

    OffsetDateTime getDueAt();

    OffsetDateTime getCompletedAt();
}
