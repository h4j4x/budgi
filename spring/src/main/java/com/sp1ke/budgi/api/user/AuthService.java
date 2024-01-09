package com.sp1ke.budgi.api.user;

import jakarta.validation.constraints.NotNull;
import java.util.Optional;

public interface AuthService {
    @NotNull
    ApiUser createUser(@NotNull ApiUser apiUser);

    @NotNull
    ApiUser findUser(@NotNull ApiUser apiUser);

    Optional<ApiUser> findUser(@NotNull String email);
}
