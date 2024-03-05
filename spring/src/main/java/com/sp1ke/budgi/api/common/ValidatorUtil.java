package com.sp1ke.budgi.api.common;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.web.client.HttpClientErrorException;

public interface ValidatorUtil {
    public static void validate(@NotNull Validator validator, @NotNull Object object) {
        var violations = validator.validate(object);
        if (!violations.isEmpty()) {
            var violationsMessage = String.join(
                ". ", violations.stream().map(ConstraintViolation::getMessage).toList());
            throw new HttpClientErrorException(HttpStatus.BAD_REQUEST, String.join(". ", violationsMessage));
        }
    }
}
