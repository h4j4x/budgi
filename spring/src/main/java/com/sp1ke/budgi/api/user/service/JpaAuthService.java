package com.sp1ke.budgi.api.user.service;

import com.sp1ke.budgi.api.common.ValidatorUtil;
import com.sp1ke.budgi.api.user.ApiUser;
import com.sp1ke.budgi.api.user.AuthService;
import com.sp1ke.budgi.api.user.domain.JpaUser;
import com.sp1ke.budgi.api.user.repo.UserRepo;
import jakarta.validation.Validator;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.lang.NonNull;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;

@Service
@RequiredArgsConstructor
public class JpaAuthService implements AuthService {
    private final UserRepo userRepo;

    private final PasswordEncoder passwordEncoder;

    private final Validator validator;

    @NonNull
    public ApiUser createUser(@NonNull ApiUser apiUser) {
        var byEmail = userRepo.findByEmail(apiUser.getEmail());
        if (byEmail.isPresent()) {
            throw new HttpClientErrorException(HttpStatus.CONFLICT, "Email already registered");
        }

        var user = JpaUser.builder()
            .name(apiUser.getName())
            .email(apiUser.getEmail())
            .password(apiUser.getPassword())
            .build();
        ValidatorUtil.validate(validator, user);

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
        throw new HttpClientErrorException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
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
