package com.spike.budgi.util;

import jakarta.validation.constraints.NotNull;
import java.util.Random;

public class StringUtil {
    public static boolean isNotBlank(String value) {
        return value != null && !value.isBlank();
    }

    public static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    @NotNull
    public static String randomString(int length) {
        var random = new Random();
        return random.ints('0', 'z' + 1)
            .filter(i -> (i <= '9' || i >= 'A') && (i <= 'Z' || i >= 'a'))
            .limit(length)
            .collect(StringBuilder::new, StringBuilder::appendCodePoint, StringBuilder::append)
            .toString();
    }
}
