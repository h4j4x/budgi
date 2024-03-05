package com.sp1ke.budgi.api.common;

public interface ObjectUtil {
    @SafeVarargs
    public static <T> T firstNonNull(T... values) {
        for (T value : values) {
            if (value != null) {
                return value;
            }
        }
        return null;
    }
}
