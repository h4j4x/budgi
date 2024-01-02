package com.sp1ke.budgi.api.common;

import java.util.Random;

public class StringUtil {
    public static String randomString(int length) {
        var random = new Random();
        return random.ints('0', 'z' + 1)
            .filter(i -> (i <= '9' || i >= 'A') && (i <= 'Z' || i >= 'a'))
            .limit(length)
            .collect(StringBuilder::new, StringBuilder::appendCodePoint, StringBuilder::append)
            .toString();
    }
}
