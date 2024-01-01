package com.sp1ke.budgi.api.user;

import com.sp1ke.budgi.api.error.BadRequestException;
import com.sp1ke.budgi.api.user.domain.JpaUser;
import com.sp1ke.budgi.api.user.repository.UserRepo;
import jakarta.validation.Validator;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final UserRepo userRepo;

    private final PasswordEncoder passwordEncoder;

    private final Validator validator;

    @NonNull
    public ApiUser createUser(@NonNull ApiUser apiUser) {
        var byEmail = userRepo.findByEmail(apiUser.getEmail());
        if (byEmail.isPresent()) {
            // TODO: proper exception
            throw new LockedException("Email already registered");
        }

        var user = JpaUser.builder()
            .name(apiUser.getName())
            .email(apiUser.getEmail())
            .password(apiUser.getPassword())
            .build();
        var violations = validator.validate(user);
        if (!violations.isEmpty()) {
            throw new BadRequestException(violations);
        }

        user.fixPassword(passwordEncoder);
        user = userRepo.save(user);
        return mapToApiUser(user);
    }

    @NonNull
    public ApiUser findUser(@NonNull ApiUser apiUser) {
        var byEmail = userRepo.findByEmail(apiUser.getEmail());
        if (byEmail.isPresent() && passwordEncoder.matches(apiUser.getPassword(), byEmail.get().getPassword())) {
            return mapToApiUser(byEmail.get());
        }
        // TODO: proper exception
        throw new BadCredentialsException("Invalid credentials");
    }

    public Optional<ApiUser> findUser(@NonNull String email) {
        return userRepo
            .findByEmail(email)
            .map(this::mapToApiUser);
    }

    @NonNull
    private ApiUser mapToApiUser(@NonNull JpaUser user) {
        return ApiUser.builder()
            .name(user.getName())
            .email(user.getEmail())
            .build();
    }
}
