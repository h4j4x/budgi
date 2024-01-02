package com.sp1ke.budgi.api.common;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;
import org.springframework.http.HttpStatus;
import org.springframework.lang.NonNull;
import org.springframework.web.client.HttpClientErrorException;

public class ValidatorUtil {
    public static void validate(@NonNull Validator validator, @NonNull Object object) {
        var violations = validator.validate(object);
        if (!violations.isEmpty()) {
            var violationsMessage = String.join(
                ". ", violations.stream().map(ConstraintViolation::getMessage).toList());
            throw new HttpClientErrorException(HttpStatus.BAD_REQUEST, String.join(". ", violationsMessage));
        }
    }
}
