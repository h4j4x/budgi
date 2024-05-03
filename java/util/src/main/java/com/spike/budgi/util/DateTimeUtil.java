package com.spike.budgi.util;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;

public class DateTimeUtil {
    @NotNull
    public static LocalDate nextDayOfMonth(@NotNull Short day) {
        var now = LocalDate.now();
        var dateTime = now.withDayOfMonth(day);
        if (dateTime.isBefore(now)) {
            dateTime = dateTime.plusMonths(1);
        }
        return dateTime;
    }

    @NotNull
    public static OffsetDateTime toOffsetDateTime(@NotNull LocalDate date) {
        return date.atStartOfDay(ZoneId.systemDefault()).toOffsetDateTime();
    }
}
