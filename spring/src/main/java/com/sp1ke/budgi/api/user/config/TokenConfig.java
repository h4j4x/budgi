package com.sp1ke.budgi.api.user.config;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "token")
@Getter
@Setter
public class TokenConfig {
    @NotBlank
    private String secret;

    private int expirationInDays;
}
