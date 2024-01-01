package com.sp1ke.budgi.api.user;

import java.time.OffsetDateTime;
import lombok.Builder;

@Builder
public class ApiToken {
    private String token;

    private String tokenType;

    private OffsetDateTime expiresAt;
}
