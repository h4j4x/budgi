package com.sp1ke.budgi.api.user;

import org.springframework.lang.NonNull;

public interface TokenService {
    @NonNull
    String getTokenType();

    @NonNull
    String extractUsername(@NonNull String token);

    @NonNull
    ApiToken generateToken(@NonNull ApiUser apiUser);
}
