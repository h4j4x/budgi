package com.sp1ke.budgi.api.util;

import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.Calendar;
import org.springframework.lang.NonNull;

public class DateTimeUtils {
    @NonNull
    public static OffsetDateTime calendarToOffsetDateTime(@NonNull Calendar calendar) {
        return OffsetDateTime.ofInstant(calendar.toInstant(), ZoneId.systemDefault());
    }
}
