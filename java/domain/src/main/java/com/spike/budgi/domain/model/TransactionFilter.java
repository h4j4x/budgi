package com.spike.budgi.domain.model;

import com.spike.budgi.util.DateTimeUtil;
import java.time.OffsetDateTime;

public record TransactionFilter(OffsetDateTime from, OffsetDateTime to,
                                Account account,
                                Category category,
                                Boolean completed) {
    public static TransactionFilter empty() {
        return new TransactionFilter(null, null, null, null, null);
    }

    public static TransactionFilter of(OffsetDateTime from, OffsetDateTime to) {
        return new TransactionFilter(from, to, null, null, null);
    }

    public static TransactionFilter of(DatePeriod period, Category category, Boolean completed) {
        var from = DateTimeUtil.toOffsetDateTime(period.from());
        var to = DateTimeUtil.toOffsetDateTime(period.to());
        return new TransactionFilter(from, to, null, category, completed);
    }
}
