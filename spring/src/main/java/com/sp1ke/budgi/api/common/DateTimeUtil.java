package com.sp1ke.budgi.api.common;

import jakarta.annotation.Nullable;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.Calendar;

public class DateTimeUtil {
    @NotNull
    public static OffsetDateTime calendarToOffsetDateTime(@NotNull Calendar calendar) {
        return OffsetDateTime.ofInstant(calendar.toInstant(), ZoneId.systemDefault());
    }

    @Nullable
    public static LocalDate parseLocalDate(@Nullable String value) {
        try {
            if (value != null) {
                return LocalDate.parse(value);
            }
        } catch (Exception ignored) {
        }
        return null;
    }
}
