package com.spike.budgi.domain.model;

import com.spike.budgi.util.ValidatorUtil;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;

public interface Validatable {
    default void validate(@NotNull Validator validator) {
        ValidatorUtil.validate(validator, this);
    }
}
