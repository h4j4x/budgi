package com.spike.budgi.util;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;

public class DateTimeUtil {
    @NotNull
    public static LocalDate nextDayOfMonth(@NotNull Short day) {
        return nextDayOfMonth(day, LocalDate.now());
    }

    @NotNull
    public static LocalDate nextDayOfMonth(@NotNull Short day, @NotNull LocalDate date) {
        var dateTime = date.withDayOfMonth(day);
        if (dateTime.isBefore(date)) {
            dateTime = dateTime.plusMonths(1);
        }
        return dateTime;
    }

    @NotNull
    public static OffsetDateTime toOffsetDateTime(@NotNull LocalDate date) {
        return date.atStartOfDay(ZoneId.systemDefault()).toOffsetDateTime();
    }
}
