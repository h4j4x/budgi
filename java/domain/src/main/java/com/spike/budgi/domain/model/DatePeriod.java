package com.spike.budgi.domain.model;

import com.spike.budgi.util.DateTimeUtil;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.OffsetDateTime;

public record DatePeriod(@NotNull LocalDate from, @NotNull LocalDate to) {
    @NotNull
    public OffsetDateTime fromDateTime() {
        return DateTimeUtil.toOffsetDateTime(from);
    }

    @NotNull
    public OffsetDateTime toDateTime() {
        return DateTimeUtil.toOffsetDateTime(to);
    }
}
