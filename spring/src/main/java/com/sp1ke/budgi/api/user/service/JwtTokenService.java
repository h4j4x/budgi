package com.sp1ke.budgi.api.user.service;

import com.sp1ke.budgi.api.user.ApiToken;
import com.sp1ke.budgi.api.user.ApiUser;
import com.sp1ke.budgi.api.user.TokenService;
import com.sp1ke.budgi.api.user.config.TokenConfig;
import com.sp1ke.budgi.api.util.DateTimeUtils;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import java.util.Calendar;
import javax.crypto.SecretKey;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Service;

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
    @NonNull
    public String getTokenType() {
        return TOKEN_TYPE;
    }

    @Override
    @NonNull
    public String extractUsername(@NonNull String token) {
        try {
            var jwt = Jwts.parser()
                .requireIssuer(ISSUER)
                .requireAudience(AUDIENCE)
                .verifyWith(signingKey)
                .build()
                .parseSignedClaims(token); // TODO: validate expiration
            return jwt.getPayload().getSubject();
        } catch (Exception ignored) {
            throw new BadCredentialsException("Invalid token");
        }
    }

    @Override
    @NonNull
    public ApiToken generateToken(@NonNull ApiUser apiUser) {
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
            .expiresAt(DateTimeUtils.calendarToOffsetDateTime(expiresAt))
            .build();
    }
}
