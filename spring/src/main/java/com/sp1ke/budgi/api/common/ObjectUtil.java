package com.sp1ke.budgi.api.common;

import org.springframework.lang.Nullable;

public interface ObjectUtil {
    @SafeVarargs
    @Nullable
    static <T> T firstNonNull(@Nullable T... values) {
        if (values != null) {
            for (T value : values) {
                if (value != null) {
                    return value;
                }
            }
        }
        return null;
    }
}
