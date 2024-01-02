package com.sp1ke.budgi.api.user;

import java.util.Optional;
import org.springframework.lang.NonNull;

public interface AuthService {
    @NonNull
    ApiUser createUser(@NonNull ApiUser apiUser);

    @NonNull
    ApiUser findUser(@NonNull ApiUser apiUser);

    Optional<ApiUser> findUser(@NonNull String email);
}
