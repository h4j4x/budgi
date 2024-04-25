package com.spike.budgi.domain;

import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.User;
import com.spike.budgi.domain.repo.UserRepo;
import com.spike.budgi.util.ValidatorUtil;
import jakarta.validation.ValidationException;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepo userRepo;

    private final Validator validator;

    @NotNull
    public User createUser(@NotNull User user) throws ConflictException {
        var byEmail = userRepo.findByCode(user.getCode());
        if (byEmail.isPresent()) {
            throw new ConflictException("User code already registered.");
        }

        validateUserCode(user);

        var jpaUser = JpaUser.builder()
            .name(user.getName())
            .code(user.getCode())
            .codeType(user.getCodeType())
            .password(user.getPassword())
            .build();
        ValidatorUtil.validate(validator, user);

        return userRepo.save(jpaUser);
    }

    @NotNull
    public Optional<User> findUser(@NotNull String code) {
        return userRepo.findByCode(code).map(jpaUser -> jpaUser);
    }

    @NotNull
    public User updateUser(@NotNull String code, @NotNull User user) throws ConflictException {
        var byCode = userRepo.findByCode(code);
        if (byCode.isEmpty()) {
            throw new ValidationException("User code is not valid.");
        }

        if (!code.equals(user.getCode())) {
            var byEmail = userRepo.findByCode(user.getCode());
            if (byEmail.isPresent()) {
                throw new ConflictException("User code already registered.");
            }
        }

        validateUserCode(user);

        var jpaUser = byCode.get().toBuilder()
            .name(user.getName())
            .code(user.getCode())
            .codeType(user.getCodeType())
            .password(user.getPassword())
            .build();
        ValidatorUtil.validate(validator, user);

        return userRepo.save(jpaUser);
    }

    private void validateUserCode(@NotNull User user) {
        switch (user.getCodeType()) {
            case null -> throw new ValidationException("User code type is required.");
            case EMAIL -> ValidatorUtil.validateEmail(user.getCode(), "User email must be valid.");
        }
    }
}
