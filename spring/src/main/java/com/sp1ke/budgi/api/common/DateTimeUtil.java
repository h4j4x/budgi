package com.sp1ke.budgi.api.common;

import jakarta.annotation.Nullable;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import org.springframework.data.util.Pair;

public interface DateTimeUtil {
    @NotNull
    static OffsetDateTime calendarToOffsetDateTime(@NotNull Calendar calendar) {
        return OffsetDateTime.ofInstant(calendar.toInstant(), ZoneId.systemDefault());
    }

    @Nullable
    static LocalDate parseLocalDate(@Nullable String value) {
        if (value != null) {
            var formats = new String[] {
                "yyyy-MM-dd", "dd-MM-yyyy",
                "yyyy/MM/dd", "dd/MM/yyyy",
                "yyyyMMdd", "ddMMyyyy"
            };
            for (var format : formats) {
                try {
                    var formatter = DateTimeFormatter.ofPattern(format);
                    return LocalDate.parse(value, formatter);
                } catch (Exception ignored) {
                }
            }
        }
        return null;
    }

    @Nullable
    static OffsetDateTime localDateToOffsetDateTime(@Nullable LocalDate date) {
        if (date != null) {
            return date.atStartOfDay(ZoneId.systemDefault()).toOffsetDateTime();
        }
        return null;
    }

    @NotNull
    static Pair<LocalDate, LocalDate> findDatesPeriod(@NotNull OffsetDateTime dateTime,
                                                      @NotNull PeriodType periodType) {
        // defaults MONTHLY
        var yearMonth = YearMonth.of(dateTime.getYear(), dateTime.getMonth());
        var fromDate = yearMonth.atDay(1);
        var toDate = yearMonth.atDay(yearMonth.lengthOfMonth());
        return Pair.of(fromDate, toDate);
    }
}
