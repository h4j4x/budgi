package com.sp1ke.budgi.api.common;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class DateTimeUtilTests {
    @Test
    void parseLocalDateWithOnlyNumbers() {
        var date = LocalDate.now();
        var formats = new String[] {
            "yyyy-MM-dd", "dd-MM-yyyy",
            "yyyy/MM/dd", "dd/MM/yyyy",
            "yyyyMMdd", "ddMMyyyy"
        };
        for (var format : formats) {
            var formatter = DateTimeFormatter.ofPattern(format);
            var dateString = formatter.format(date);
            var parsedDate = DateTimeUtil.parseLocalDate(dateString);
            assertEquals(date, parsedDate);
        }
    }
}
