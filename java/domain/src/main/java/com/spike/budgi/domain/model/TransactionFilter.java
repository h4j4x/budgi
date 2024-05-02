package com.spike.budgi.domain.model;

import java.time.OffsetDateTime;

public record TransactionFilter(OffsetDateTime from, OffsetDateTime to,
                                Account account,
                                Category category,
                                Boolean completed) {
    public static TransactionFilter empty() {
        return new TransactionFilter(null, null, null, null, null);
    }

    public static TransactionFilter of(OffsetDateTime from, OffsetDateTime to, Category category, Boolean completed) {
        return new TransactionFilter(from, to, null, category, completed);
    }
}
