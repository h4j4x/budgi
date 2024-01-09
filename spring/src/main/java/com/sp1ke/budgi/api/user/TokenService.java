package com.sp1ke.budgi.api.user;

import jakarta.validation.constraints.NotNull;

public interface TokenService {
    @NotNull
    String extractUsername(@NotNull String token);

    @NotNull
    ApiToken generateToken(@NotNull ApiUser apiUser);
}
