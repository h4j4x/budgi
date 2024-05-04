package com.spike.budgi.domain.model;

import java.time.OffsetDateTime;

public record TransactionFilter(OffsetDateTime from, OffsetDateTime to,
                                Account account,
                                Category category) {
    public static TransactionFilter empty() {
        return new TransactionFilter(null, null, null, null);
    }

    public static TransactionFilter of(OffsetDateTime from, OffsetDateTime to) {
        return new TransactionFilter(from, to, null, null);
    }

    public static TransactionFilter of(DatePeriod period, Category category) {
        return new TransactionFilter(period.fromDateTime(), period.toDateTime(), null, category);
    }
}
