package com.spike.budgi.domain.service;

import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.error.NotFoundException;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.User;
import com.spike.budgi.domain.repo.UserRepo;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.util.Optional;
import java.util.function.Supplier;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepo userRepo;

    private final Validator validator;

    @NotNull
    public User createUser(@NotNull User user) throws ConflictException {
        var byCode = userRepo.findByCode(user.getCode());
        if (byCode.isPresent()) {
            throw new ConflictException("User code already registered.");
        }

        var jpaUser = build(user, JpaUser::builder);
        jpaUser.validate(validator);

        return userRepo.save(jpaUser);
    }

    @NotNull
    public Optional<User> findUser(@NotNull String code) {
        return userRepo.findByCode(code).map(jpaUser -> jpaUser);
    }

    @NotNull
    public User updateUser(@NotNull String code, @NotNull User user) throws ConflictException, NotFoundException {
        var byCode = userRepo.findByCode(code);
        if (byCode.isEmpty()) {
            throw new NotFoundException("User code is not valid.");
        }

        if (!code.equals(user.getCode())) {
            var duplicated = userRepo.findByCode(user.getCode());
            if (duplicated.isPresent()) {
                throw new ConflictException("User code already registered.");
            }
        }

        var jpaUser = build(user, () -> byCode.get().toBuilder());
        jpaUser.validate(validator);

        return userRepo.save(jpaUser);
    }

    private JpaUser build(@NotNull User user,
                          @NotNull Supplier<JpaUser.JpaUserBuilder<?, ?>> builderSupplier) {
        return builderSupplier.get()
            .name(user.getName())
            .code(user.getCode())
            .codeType(user.getCodeType())
            .password(user.getPassword())
            .build();
    }
}
