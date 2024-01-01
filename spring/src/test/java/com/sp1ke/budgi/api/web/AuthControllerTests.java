package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.error.ApiMessage;
import com.sp1ke.budgi.api.user.ApiToken;
import com.sp1ke.budgi.api.user.ApiUser;
import com.sp1ke.budgi.api.user.domain.JpaUser;
import com.sp1ke.budgi.api.user.repository.UserRepo;
import jakarta.validation.Validator;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.lang.NonNull;
import org.springframework.security.crypto.password.PasswordEncoder;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class AuthControllerTests {
    private final int port;

    private final Validator validator;

    private final UserRepo userRepo;

    private final PasswordEncoder passwordEncoder;

    private final TestRestTemplate rest;

    @Autowired
    public AuthControllerTests(@LocalServerPort int port,
                               Validator validator,
                               UserRepo userRepo,
                               PasswordEncoder passwordEncoder) {
        this.port = port;
        this.validator = validator;
        this.userRepo = userRepo;
        this.passwordEncoder = passwordEncoder;
        rest = new TestRestTemplate();
    }

    @BeforeEach
    void beforeEach() {
        userRepo.deleteAll();
    }

    @Test
    public void signUpReturnsApiToken() {
        var user = ApiUser.builder()
            .name("Test")
            .email("test@mail.com")
            .password("test")
            .build();
        var body = new HttpEntity<>(user);
        var response = rest.postForEntity(url("/signup"), body, ApiToken.class);

        assertEquals(201, response.getStatusCode().value());
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
    public void signUpInvalidThrowsException() {
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

            var body = new HttpEntity<>(user);
            var response = rest.postForEntity(url("/signup"), body, ApiMessage.class);
            assertEquals(400, response.getStatusCode().value());
            var apiMessage = response.getBody();
            assertNotNull(apiMessage);
            assertNotNull(apiMessage.getMessage());
            for (var violation : violations) {
                assertTrue(apiMessage.getMessage().contains(violation.getMessage()));
            }
        }
    }

    @Test
    public void signInReturnsApiToken() {
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
        var body = new HttpEntity<>(user);
        var response = rest.postForEntity(url("/signin"), body, ApiToken.class);

        assertEquals(200, response.getStatusCode().value());
        var apiToken = response.getBody();
        assertNotNull(apiToken);
        assertNotNull(apiToken.getToken());
        assertEquals("Bearer", apiToken.getTokenType());
        assertNotNull(apiToken.getExpiresAt());
        assertTrue(apiToken.getExpiresAt().isAfter(OffsetDateTime.now()));
    }

    @Test
    public void signInInvalidThrowsException() {
        var user = ApiUser.builder()
            .email("test@mail.com")
            .password("password")
            .build();
        var body = new HttpEntity<>(user);
        var response = rest.postForEntity(url("/signin"), body, ApiMessage.class);
        assertEquals(401, response.getStatusCode().value());
    }

    @Test
    public void meValidTokenReturnsUser() {
        var user = ApiUser.builder()
            .name("Test")
            .email("test@mail.com")
            .password("test")
            .build();
        var body = new HttpEntity<>(user);
        var signUpResponse = rest.postForEntity(url("/signup"), body, ApiToken.class);

        assertEquals(201, signUpResponse.getStatusCode().value());
        var apiToken = signUpResponse.getBody();
        assertNotNull(apiToken);
        assertNotNull(apiToken.getToken());

        var headers = new HttpHeaders();
        headers.add("Authorization", apiToken.getTokenType() + " " + apiToken.getToken());
        headers.add("Content-Type", MediaType.APPLICATION_JSON_VALUE);
        var entity = new HttpEntity<>(headers);
        var response = rest.exchange(url("/me"), HttpMethod.GET, entity, ApiUser.class);
        assertEquals(200, response.getStatusCode().value());
        var apiUser = response.getBody();
        assertNotNull(apiUser);
        assertEquals(user.getName(), apiUser.getName());
        assertEquals(user.getEmail(), apiUser.getEmail());
    }

    @Test
    public void meWithoutTokenThrowsException() {
        var response = rest.getForEntity(url("/me"), ApiMessage.class);
        assertEquals(403, response.getStatusCode().value());
    }

    @NonNull
    private String url(@NonNull String endpoint) {
        return String.format("http://localhost:%d/auth%s", port, endpoint);
    }
}
