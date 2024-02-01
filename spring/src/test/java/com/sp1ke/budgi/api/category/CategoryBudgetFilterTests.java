package com.sp1ke.budgi.api.category;

import java.time.YearMonth;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

public class CategoryBudgetFilterTests {
    @Test
    void defaultDatesFromCurrentMonth() {
        var filter = new CategoryBudgetFilter();
        var now = YearMonth.now();
        var fromDate = filter.fromDate();
        var toDate = filter.toDate();
        assertNotNull(fromDate);
        assertNotNull(toDate);
        assertEquals(now.getYear(), fromDate.getYear());
        assertEquals(now.getYear(), toDate.getYear());
        assertEquals(now.getMonth(), fromDate.getMonth());
        assertEquals(now.getMonth(), toDate.getMonth());
        assertEquals(1, fromDate.getDayOfMonth());
        assertEquals(now.atEndOfMonth().getDayOfMonth(), toDate.getDayOfMonth());
    }
}
