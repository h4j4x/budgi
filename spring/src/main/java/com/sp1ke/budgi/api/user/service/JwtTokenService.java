package com.sp1ke.budgi.api.user.service;

import com.sp1ke.budgi.api.common.DateTimeUtil;
import com.sp1ke.budgi.api.common.StringUtil;
import com.sp1ke.budgi.api.user.ApiToken;
import com.sp1ke.budgi.api.user.ApiUser;
import com.sp1ke.budgi.api.user.TokenService;
import com.sp1ke.budgi.api.user.config.TokenConfig;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import jakarta.validation.constraints.NotNull;
import java.util.Calendar;
import javax.crypto.SecretKey;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;

// https://github.com/jwtk/jjwt
@Service
@EnableConfigurationProperties(TokenConfig.class)
public class JwtTokenService implements TokenService {
    private static final String ISSUER = "budgi";

    private static final String AUDIENCE = "api";

    private static final String TOKEN_TYPE = "Bearer";

    private final SecretKey signingKey;

    private final int tokenExpirationInDays;

    public JwtTokenService(TokenConfig tokenConfig) {
        signingKey = Keys.hmacShaKeyFor(Decoders.BASE64.decode(tokenConfig.getSecret()));
        tokenExpirationInDays = tokenConfig.getExpirationInDays();
    }

    @Override
    @NotNull
    public String extractUsername(@NotNull String token) {
        try {
            var jwt = Jwts.parser()
                .requireIssuer(ISSUER)
                .requireAudience(AUDIENCE)
                .verifyWith(signingKey)
                .build()
                .parseSignedClaims(StringUtil.removePrefix(token, TOKEN_TYPE + " "));
            // TODO: validate expiration
            return jwt.getPayload().getSubject();
        } catch (Exception ignored) {
            throw new HttpClientErrorException(HttpStatus.UNAUTHORIZED, "Invalid token");
        }
    }

    @Override
    @NotNull
    public ApiToken generateToken(@NotNull ApiUser apiUser) {
        var expiresAt = Calendar.getInstance();
        expiresAt.add(Calendar.DAY_OF_MONTH, tokenExpirationInDays);
        var token = Jwts.builder()
            .subject(apiUser.getEmail())
            .issuer(ISSUER)
            .audience().add(AUDIENCE).and()
            .expiration(expiresAt.getTime())
            .signWith(signingKey)
            .compact();
        return ApiToken.builder()
            .token(token)
            .tokenType(TOKEN_TYPE)
            .expiresAt(DateTimeUtil.calendarToOffsetDateTime(expiresAt))
            .build();
    }
}
