package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.category.ApiCategory;
import com.sp1ke.budgi.api.category.domain.JpaCategory;
import com.sp1ke.budgi.api.category.repo.CategoryRepo;
import com.sp1ke.budgi.api.helper.AuthHelper;
import com.sp1ke.budgi.api.helper.RestResponsePage;
import com.sp1ke.budgi.api.user.repo.UserRepo;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.client.RestClient;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class CategoryControllerTests {
    private final UserRepo userRepo;

    private final CategoryRepo categoryRepo;

    private final PasswordEncoder passwordEncoder;

    private final RestClient restClient;

    @Autowired
    public CategoryControllerTests(@LocalServerPort int port,
                                   UserRepo userRepo,
                                   CategoryRepo categoryRepo,
                                   PasswordEncoder passwordEncoder) {
        this.userRepo = userRepo;
        this.categoryRepo = categoryRepo;
        this.passwordEncoder = passwordEncoder;
        restClient = RestClient.builder()
            .baseUrl(String.format("http://localhost:%d", port))
            .defaultHeader("Content-Type", MediaType.APPLICATION_JSON_VALUE)
            .build();
    }

    @BeforeEach
    void beforeEach() {
        categoryRepo.deleteAll();
        userRepo.deleteAll();
    }

    @Test
    void createValidWithoutCodeReturnsCode() {
        var authTokenPair = AuthHelper.fetchAuthToken(userRepo, passwordEncoder, restClient);
        var category = ApiCategory.builder().name("Test").build();

        var response = restClient.post()
            .uri("/category")
            .header("Authorization", "Bearer " + authTokenPair.getSecond())
            .body(category)
            .retrieve()
            .toEntity(ApiCategory.class);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        var apiCategory = response.getBody();
        assertNotNull(apiCategory);
        assertNotNull(apiCategory.getCode());
        assertEquals(category.getName(), apiCategory.getName());

        Optional<JpaCategory> byCode = categoryRepo
            .findByUserIdAndCode(authTokenPair.getFirst(), apiCategory.getCode());
        assertTrue(byCode.isPresent());
        assertEquals(category.getName(), byCode.get().getName());
    }

    @Test
    void createValidWithCodeKeepsCode() {
        var authTokenPair = AuthHelper.fetchAuthToken(userRepo, passwordEncoder, restClient);
        var category = ApiCategory.builder()
            .code("test")
            .name("Test")
            .build();

        var response = restClient.post()
            .uri("/category")
            .header("Authorization", "Bearer " + authTokenPair.getSecond())
            .contentType(MediaType.APPLICATION_JSON)
            .accept(MediaType.APPLICATION_JSON)
            .body(category)
            .retrieve()
            .toEntity(ApiCategory.class);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        var apiCategory = response.getBody();
        assertNotNull(apiCategory);
        assertEquals(category.getCode(), apiCategory.getCode());
        assertEquals(category.getName(), apiCategory.getName());

        Optional<JpaCategory> byCode = categoryRepo
            .findByUserIdAndCode(authTokenPair.getFirst(), apiCategory.getCode());
        assertTrue(byCode.isPresent());
        assertEquals(category.getName(), byCode.get().getName());
    }

    @Test
    void fetchPageReturnsUserItems() {
        var authTokenPair = AuthHelper.fetchAuthToken(userRepo, passwordEncoder, restClient);
        for (int i = 1; i < 9; i++) {
            var category = JpaCategory.builder()
                .userId(authTokenPair.getFirst() + i % 2)
                .code("test" + i)
                .name("Test " + i)
                .build();
            categoryRepo.save(category);
        }

        var response = restClient.get()
            .uri("/category")
            .header("Authorization", "Bearer " + authTokenPair.getSecond())
            .retrieve()
            .toEntity(new ParameterizedTypeReference<RestResponsePage<ApiCategory>>() {
            });

        assertEquals(HttpStatus.OK, response.getStatusCode());
        var page = response.getBody();
        assertNotNull(page);
        assertEquals(4L, page.getTotalElements());
    }
}
