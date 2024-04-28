package com.spike.budgi.util;

import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;

public class DateTimeUtil {
    @NotNull
    public static OffsetDateTime nextDayOfMonth(@NotNull Short day) {
        var now = OffsetDateTime.now();
        var dateTime = now.withDayOfMonth(day);
        if (dateTime.isBefore(now)) {
            dateTime = dateTime.plusMonths(1);
        }
        return dateTime;
    }
}
