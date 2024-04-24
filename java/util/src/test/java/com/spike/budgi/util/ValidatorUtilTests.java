package com.spike.budgi.util;

import jakarta.validation.ValidationException;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

public class ValidatorUtilTests {
    @Test
    void testValidateEmail() {
        ValidatorUtil.validateEmail("valid@mail.com", "");

        var message = "Test error";
        var validationException = assertThrows(ValidationException.class,
            () -> ValidatorUtil.validateEmail("no-valid#mail.com", message));
        assertEquals(message, validationException.getMessage());
    }
}
