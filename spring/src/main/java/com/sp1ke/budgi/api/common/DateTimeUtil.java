package com.sp1ke.budgi.api.common;

import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.Calendar;
import org.springframework.lang.NonNull;

public class DateTimeUtil {
    @NonNull
    public static OffsetDateTime calendarToOffsetDateTime(@NonNull Calendar calendar) {
        return OffsetDateTime.ofInstant(calendar.toInstant(), ZoneId.systemDefault());
    }
}
