package com.spike.budgi.domain.jpa;

import com.spike.budgi.domain.model.User;
import com.spike.budgi.domain.model.UserCodeType;
import com.spike.budgi.util.ValidatorUtil;
import jakarta.persistence.*;
import jakarta.validation.ValidationException;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@Getter
@NoArgsConstructor
@Setter
@SuperBuilder(toBuilder = true)
@Table(name = "users", indexes = {
    @Index(name = "users_code_UNQ", columnList = "code", unique = true),
})
public class JpaUser extends JpaBase implements User {
    @Column(length = 100, nullable = false)
    @NotBlank(message = "User name is required.")
    @Size(max = 100, min = 3, message = "User name must have between 3 and 100 characters length.")
    private String name;

    @Column(length = 50, name = "code_type", nullable = false)
    @Enumerated(EnumType.STRING)
    @NotNull(message = "User code type is required.")
    private UserCodeType codeType;

    @Size(max = 500, min = 3, message = "User password must have between 3 and 500 characters length.")
    @Column(length = 500)
    private String password;

    @Override
    public void validate(Validator validator) {
        switch (codeType) {
            case null -> throw new ValidationException("User code type is required.");
            case EMAIL -> ValidatorUtil.validateEmail(getCode(), "User email must be valid.");
        }
        User.super.validate(validator);
    }
}
