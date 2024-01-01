package com.sp1ke.budgi.api.error;

import jakarta.validation.ConstraintViolation;
import java.util.Set;
import org.springframework.lang.NonNull;

public class BadRequestException extends RuntimeException {
    public <T> BadRequestException(@NonNull Set<ConstraintViolation<T>> violations) {
        super(String.join(". ", violations.stream().map(ConstraintViolation::getMessage).toList()));
    }
}
