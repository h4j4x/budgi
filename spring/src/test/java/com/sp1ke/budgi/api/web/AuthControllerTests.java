package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.common.ApiMessage;
import com.sp1ke.budgi.api.user.ApiToken;
import com.sp1ke.budgi.api.user.ApiUser;
import com.sp1ke.budgi.api.user.domain.JpaUser;
import com.sp1ke.budgi.api.user.repo.UserRepo;
import jakarta.validation.Validator;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClient;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class AuthControllerTests {
    private final Validator validator;

    private final UserRepo userRepo;

    private final PasswordEncoder passwordEncoder;

    private final RestClient restClient;

    @Autowired
    public AuthControllerTests(@LocalServerPort int port,
                               Validator validator,
                               UserRepo userRepo,
                               PasswordEncoder passwordEncoder) {
        this.validator = validator;
        this.userRepo = userRepo;
        this.passwordEncoder = passwordEncoder;
        restClient = RestClient.builder()
            .baseUrl(String.format("http://localhost:%d/auth", port))
            .defaultHeader("Content-Type", MediaType.APPLICATION_JSON_VALUE)
            .build();
    }

    @BeforeEach
    void beforeEach() {
        userRepo.deleteAll();
    }

    @Test
    void signUpReturnsApiToken() {
        var user = ApiUser.builder()
            .name("Test")
            .email("test@mail.com")
            .password("test")
            .build();
        var response = restClient.post()
            .uri("/signup")
            .body(user)
            .retrieve()
            .toEntity(ApiToken.class);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        var apiToken = response.getBody();
        assertNotNull(apiToken);
        assertNotNull(apiToken.getToken());
        assertEquals("Bearer", apiToken.getTokenType());
        assertNotNull(apiToken.getExpiresAt());
        assertTrue(apiToken.getExpiresAt().isAfter(OffsetDateTime.now()));

        Optional<JpaUser> byEmail = userRepo.findByEmail(user.getEmail());
        assertTrue(byEmail.isPresent());
        assertEquals(user.getName(), byEmail.get().getName());
        assertNotEquals(user.getPassword(), byEmail.get().getPassword());
    }

    @Test
    void signUpInvalidThrowsException() {
        var users = List.of(
            ApiUser.builder().name("test").build(),
            ApiUser.builder().email("test@mail.com").build(),
            ApiUser.builder().password("test").build(),
            ApiUser.builder().build(),
            ApiUser.builder().name("-").email("test@mail.com").password("-").build()
        );
        for (var apiUser : users) {
            var user = JpaUser.builder()
                .name(apiUser.getName())
                .email(apiUser.getEmail())
                .password(apiUser.getPassword())
                .build();
            var violations = validator.validate(user);
            assertFalse(violations.isEmpty());

            try {
                restClient.post()
                    .uri("/signup")
                    .body(user)
                    .retrieve()
                    .toEntity(ApiMessage.class);
                fail();
            } catch (HttpClientErrorException e) {
                assertEquals(HttpStatus.BAD_REQUEST, e.getStatusCode());
                assertNotNull(e.getMessage());
                for (var violation : violations) {
                    assertTrue(e.getMessage().contains(violation.getMessage()));
                }
            } catch (Exception e) {
                fail(e.getMessage());
            }
        }
    }

    @Test
    void signInReturnsApiToken() {
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
            .uri("/signin")
            .body(user)
            .retrieve()
            .toEntity(ApiToken.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        var apiToken = response.getBody();
        assertNotNull(apiToken);
        assertNotNull(apiToken.getToken());
        assertEquals("Bearer", apiToken.getTokenType());
        assertNotNull(apiToken.getExpiresAt());
        assertTrue(apiToken.getExpiresAt().isAfter(OffsetDateTime.now()));
    }

    @Test
    void signInInvalidThrowsException() {
        var user = ApiUser.builder()
            .email("test@mail.com")
            .password("password")
            .build();
        try {
            restClient.post()
                .uri("/signin")
                .body(user)
                .retrieve()
                .toEntity(ApiMessage.class);
        } catch (HttpClientErrorException e) {
            assertEquals(HttpStatus.UNAUTHORIZED, e.getStatusCode());
        } catch (Exception e) {
            fail(e.getMessage());
        }
    }

    @Test
    void meValidTokenReturnsUser() {
        var user = ApiUser.builder()
            .name("Test")
            .email("test@mail.com")
            .password("test")
            .build();
        var signUpResponse = restClient.post()
            .uri("/signup")
            .body(user)
            .retrieve()
            .toEntity(ApiToken.class);

        assertEquals(HttpStatus.CREATED, signUpResponse.getStatusCode());
        var apiToken = signUpResponse.getBody();
        assertNotNull(apiToken);
        assertNotNull(apiToken.getToken());

        var response = restClient.get()
            .uri("/me")
            .header("Authorization", "Bearer " + apiToken.getToken())
            .retrieve()
            .toEntity(ApiUser.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        var apiUser = response.getBody();
        assertNotNull(apiUser);
        assertEquals(user.getName(), apiUser.getName());
        assertEquals(user.getEmail(), apiUser.getEmail());
    }

    @Test
    void meWithoutTokenThrowsException() {
        try {
            restClient.get()
                .uri("/me")
                .retrieve()
                .toEntity(ApiMessage.class);
            fail();
        } catch (HttpClientErrorException e) {
            assertEquals(HttpStatus.FORBIDDEN, e.getStatusCode());
        } catch (Exception e) {
            fail(e.getMessage());
        }
    }
}
