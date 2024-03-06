package com.sp1ke.budgi.api.common;

import jakarta.annotation.Nullable;
import jakarta.validation.constraints.NotNull;
import java.util.Random;

public interface StringUtil {
    @NotNull
    static String randomString(int length) {
        var random = new Random();
        return random.ints('0', 'z' + 1)
            .filter(i -> (i <= '9' || i >= 'A') && (i <= 'Z' || i >= 'a'))
            .limit(length)
            .collect(StringBuilder::new, StringBuilder::appendCodePoint, StringBuilder::append)
            .toString();
    }

    @NotNull
    static String removePrefix(@NotNull String value, @NotNull String prefix) {
        if (value.startsWith(prefix)) {
            return value.substring(prefix.length());
        }
        return value;
    }

    static boolean isNotBlank(@Nullable String value) {
        return value != null && !value.isBlank();
    }

    static boolean isBlank(@Nullable String value) {
        return value == null || value.isBlank();
    }

    static String tail(@Nullable String value, int length) {
        if (value != null) {
            if (length >= value.length()) {
                return value;
            }
            return value.substring(value.length() - length);
        }
        return null;
    }
}
