package com.sp1ke.budgi.api.user;

import java.time.OffsetDateTime;
import lombok.Builder;
import lombok.Getter;

@Builder
@Getter
public class ApiToken {
    private String token;

    private String tokenType;

    private OffsetDateTime expiresAt;
}
