package com.sp1ke.budgi.api.common;

import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.Calendar;

public class DateTimeUtil {
    @NotNull
    public static OffsetDateTime calendarToOffsetDateTime(@NotNull Calendar calendar) {
        return OffsetDateTime.ofInstant(calendar.toInstant(), ZoneId.systemDefault());
    }
}
