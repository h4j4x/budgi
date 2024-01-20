package com.sp1ke.budgi.api.helper;

import java.time.OffsetDateTime;
import java.time.temporal.ChronoUnit;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class AssertHelper {
    public static void assertOffsetDateTimeEquals(OffsetDateTime value1, OffsetDateTime value2) {
        assertEquals(
            value1.toInstant().truncatedTo(ChronoUnit.MILLIS),
            value2.toInstant().truncatedTo(ChronoUnit.MILLIS));
    }
}
