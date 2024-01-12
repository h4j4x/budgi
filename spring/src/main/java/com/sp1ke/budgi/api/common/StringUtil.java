package com.sp1ke.budgi.api.common;

import jakarta.annotation.Nullable;
import jakarta.validation.constraints.NotNull;
import java.util.Random;

public class StringUtil {
    @NotNull
    public static String randomString(int length) {
        var random = new Random();
        return random.ints('0', 'z' + 1)
            .filter(i -> (i <= '9' || i >= 'A') && (i <= 'Z' || i >= 'a'))
            .limit(length)
            .collect(StringBuilder::new, StringBuilder::appendCodePoint, StringBuilder::append)
            .toString();
    }

    @NotNull
    public static String removePrefix(@NotNull String value, @NotNull String prefix) {
        if (value.startsWith(prefix)) {
            return value.substring(prefix.length());
        }
        return value;
    }

    public static boolean isNotBlank(@Nullable String value) {
        return value != null && !value.isBlank();
    }
}
