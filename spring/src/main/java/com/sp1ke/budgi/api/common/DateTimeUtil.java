package com.sp1ke.budgi.api.common;

import jakarta.annotation.Nullable;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.YearMonth;
import java.time.ZoneId;
import java.util.Calendar;
import org.springframework.data.util.Pair;

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

    @Nullable
    public static OffsetDateTime localDateToOffsetDateTime(@Nullable LocalDate date) {
        if (date != null) {
            return date.atStartOfDay(ZoneId.systemDefault()).toOffsetDateTime();
        }
        return null;
    }

    @NotNull
    public static Pair<LocalDate, LocalDate> findDatesPeriod(@NotNull OffsetDateTime dateTime,
                                                             @NotNull PeriodType periodType) {
        // defaults MONTHLY
        var yearMonth = YearMonth.of(dateTime.getYear(), dateTime.getMonth());
        var fromDate = yearMonth.atDay(1);
        var toDate = yearMonth.atDay(yearMonth.lengthOfMonth());
        return Pair.of(fromDate, toDate);
    }
}
