package com.sp1ke.budgi.api.helper;

import com.sp1ke.budgi.api.user.ApiToken;
import com.sp1ke.budgi.api.user.ApiUser;
import com.sp1ke.budgi.api.user.domain.JpaUser;
import com.sp1ke.budgi.api.user.repo.UserRepo;
import org.springframework.data.util.Pair;
import org.springframework.lang.NonNull;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.client.RestClient;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

public class AuthHelper {
    @NonNull
    public static Pair<Long, String> fetchAuthToken(@NonNull UserRepo userRepo,
                                                    @NonNull PasswordEncoder passwordEncoder,
                                                    @NonNull RestClient restClient) {
        var password = "test";
        var jpaUser = JpaUser.builder()
            .name("Test")
            .email("test@mail.com")
            .password(passwordEncoder.encode(password))
            .build();
        userRepo.save(jpaUser);

        var user = ApiUser.builder()
            .email(jpaUser.getEmail())
            .password(password)
            .build();
        var response = restClient.post()
            .uri("/auth/signin")
            .body(user)
            .retrieve()
            .toEntity(ApiToken.class);

        assertEquals(200, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertNotNull(response.getBody().getToken());
        return Pair.of(jpaUser.getId(), response.getBody().getToken());
    }
}
