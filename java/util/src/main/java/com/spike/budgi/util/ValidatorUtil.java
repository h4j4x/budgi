package com.spike.budgi.util;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.ValidationException;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.util.regex.Pattern;

public class ValidatorUtil {
    public static void validate(@NotNull Validator validator, @NotNull Object object) {
        var violations = validator.validate(object);
        if (!violations.isEmpty()) {
            var violationsMessage = String.join(
                ". ", violations.stream().map(ConstraintViolation::getMessage).toList());
            throw new ValidationException(String.join(". ", violationsMessage));
        }
    }

    public static void validateEmail(String email, @NotNull String message) {
        if (StringUtil.isNotBlank(email)) {
            var regexPattern = "^(.+)@(\\S+)$";
            if (Pattern.compile(regexPattern).matcher(email).matches()) {
                return;
            }
        }
        throw new ValidationException(message);
    }
}
