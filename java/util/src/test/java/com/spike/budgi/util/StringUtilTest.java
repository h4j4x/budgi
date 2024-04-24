package com.spike.budgi.util;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertTrue;

class StringUtilTest {
    @Test
    void randomStringReturnsAlphanumericGivenLength() {
        var pattern = "[a-zA-Z0-9]";
        for (int length = 5; length < 20; length++) {
            var string = StringUtil.randomString(length);
            assertTrue(string.matches(String.format("%s{%d}", pattern, length)));
        }
    }
}