package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.category.ApiCategory;
import com.sp1ke.budgi.api.category.ApiCategoryBudget;
import com.sp1ke.budgi.api.category.domain.JpaCategory;
import com.sp1ke.budgi.api.category.domain.JpaCategoryBudget;
import com.sp1ke.budgi.api.category.repo.CategoryBudgetRepo;
import com.sp1ke.budgi.api.category.repo.CategoryRepo;
import com.sp1ke.budgi.api.common.StringUtil;
import com.sp1ke.budgi.api.helper.AuthHelper;
import com.sp1ke.budgi.api.helper.RestResponsePage;
import com.sp1ke.budgi.api.user.repo.UserRepo;
import java.math.BigDecimal;
import java.time.YearMonth;
import java.util.Optional;
import java.util.StringJoiner;
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

    private final CategoryBudgetRepo categoryBudgetRepo;

    private final PasswordEncoder passwordEncoder;

    private final RestClient restClient;

    @Autowired
    public CategoryControllerTests(@LocalServerPort int port,
                                   UserRepo userRepo,
                                   CategoryRepo categoryRepo,
                                   CategoryBudgetRepo categoryBudgetRepo,
                                   PasswordEncoder passwordEncoder) {
        this.userRepo = userRepo;
        this.categoryRepo = categoryRepo;
        this.categoryBudgetRepo = categoryBudgetRepo;
        this.passwordEncoder = passwordEncoder;
        restClient = RestClient.builder()
            .baseUrl(String.format("http://localhost:%d/api/v1", port))
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
        var len = 9;
        for (int i = 1; i < len; i++) {
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
        assertEquals(len / 2, page.getTotalElements());
    }

    @Test
    void createValidBudgetWithCodeKeepsCodeAndAssignCurrency() {
        var authTokenPair = AuthHelper.fetchAuthToken(userRepo, passwordEncoder, restClient);
        var category = JpaCategory.builder()
            .userId(authTokenPair.getFirst())
            .code("test")
            .name("Test")
            .build();
        category = categoryRepo.save(category);

        var fromDate = YearMonth.now().atDay(1);
        var toDate = YearMonth.now().atEndOfMonth();
        var budget = ApiCategoryBudget.builder()
            .code("test")
            .categoryCode(category.getCode())
            .amount(BigDecimal.valueOf(15.3))
            .fromDate(fromDate)
            .toDate(toDate)
            .build();

        var response = restClient.post()
            .uri("/category-budget")
            .header("Authorization", "Bearer " + authTokenPair.getSecond())
            .contentType(MediaType.APPLICATION_JSON)
            .accept(MediaType.APPLICATION_JSON)
            .body(budget)
            .retrieve()
            .toEntity(ApiCategoryBudget.class);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        var apiCategoryBudget = response.getBody();
        assertNotNull(apiCategoryBudget);
        assertEquals(budget.getCode(), apiCategoryBudget.getCode());
        assertEquals(budget.getCategoryCode(), apiCategoryBudget.getCategoryCode());
        assertNotNull(apiCategoryBudget.getCurrency());
        assertEquals(budget.getAmount().stripTrailingZeros(), apiCategoryBudget.getAmount().stripTrailingZeros());
        assertEquals(fromDate, apiCategoryBudget.getFromDate());
        assertEquals(toDate, apiCategoryBudget.getToDate());

        Optional<JpaCategoryBudget> byCode = categoryBudgetRepo
            .findByUserIdAndCode(authTokenPair.getFirst(), apiCategoryBudget.getCode());
        assertTrue(byCode.isPresent());
        assertEquals(apiCategoryBudget.getAmount().stripTrailingZeros(), byCode.get().getAmount().stripTrailingZeros());
    }

    @Test
    void fetchBudgetPageReturnsUserItems() {
        var authTokenPair = AuthHelper.fetchAuthToken(userRepo, passwordEncoder, restClient);
        var fromDate = YearMonth.now().atDay(1);
        var toDate = YearMonth.now().atEndOfMonth();
        var len = 9;
        for (var i = 1; i < len; i++) {
            var category = JpaCategory.builder()
                .userId(authTokenPair.getFirst() + i % 2)
                .code("test" + i)
                .name("Test " + i)
                .build();
            category = categoryRepo.save(category);

            var budget = JpaCategoryBudget.builder()
                .userId(authTokenPair.getFirst() + i % 2)
                .code("test-budget" + i)
                .categoryId(category.getId())
                .amount(BigDecimal.valueOf(i * 10.0))
                .fromDate(fromDate)
                .toDate(toDate)
                .build();
            categoryBudgetRepo.save(budget);
        }

        var response = restClient.get()
            .uri("/category-budget")
            .header("Authorization", "Bearer " + authTokenPair.getSecond())
            .retrieve()
            .toEntity(new ParameterizedTypeReference<RestResponsePage<ApiCategoryBudget>>() {
            });

        assertEquals(HttpStatus.OK, response.getStatusCode());
        var page = response.getBody();
        assertNotNull(page);
        assertEquals(len / 2, page.getTotalElements());
        for (var budget : page) {
            assertNotNull(budget.getCode());
            assertNotNull(budget.getCategoryCode());
            assertNotNull(budget.getCurrency());
            assertNotNull(budget.getAmount());
            var budgetIndex = Integer.parseInt(StringUtil.tail(budget.getCode(), 1));
            var budgetAmount = BigDecimal.valueOf(budgetIndex * 10.0);
            assertEquals(budgetAmount.stripTrailingZeros(), budget.getAmount().stripTrailingZeros());
            assertEquals(fromDate, budget.getFromDate());
            assertEquals(toDate, budget.getToDate());
        }
    }

    @Test
    void fetchPageIncludingCodes() {
        var authTokenPair = AuthHelper.fetchAuthToken(userRepo, passwordEncoder, restClient);
        var codes = new StringJoiner(";");
        var len = 9;
        for (int i = 1; i < len; i++) {
            var code = "test" + i;
            if (i % 2 == 0) {
                codes.add(code);
            }
            var category = JpaCategory.builder()
                .userId(authTokenPair.getFirst())
                .code(code)
                .name("Test " + i)
                .build();
            categoryRepo.save(category);
        }

        var response = restClient.get()
            .uri("/category?includingCodes=" + codes)
            .header("Authorization", "Bearer " + authTokenPair.getSecond())
            .retrieve()
            .toEntity(new ParameterizedTypeReference<RestResponsePage<ApiCategory>>() {
            });

        assertEquals(HttpStatus.OK, response.getStatusCode());
        var page = response.getBody();
        assertNotNull(page);
        assertEquals(len / 2, page.getTotalElements());
        for (var item : page) {
            assertTrue(codes.toString().contains(item.getCode()));
        }
    }

    @Test
    void fetchPageExcludingCodes() {
        var authTokenPair = AuthHelper.fetchAuthToken(userRepo, passwordEncoder, restClient);
        var codes = new StringJoiner(";");
        var len = 9;
        for (int i = 1; i < len; i++) {
            var code = "test" + i;
            if (i % 2 == 0) {
                codes.add(code);
            }
            var category = JpaCategory.builder()
                .userId(authTokenPair.getFirst())
                .code(code)
                .name("Test " + i)
                .build();
            categoryRepo.save(category);
        }

        var response = restClient.get()
            .uri("/category?excludingCodes=" + codes)
            .header("Authorization", "Bearer " + authTokenPair.getSecond())
            .retrieve()
            .toEntity(new ParameterizedTypeReference<RestResponsePage<ApiCategory>>() {
            });

        assertEquals(HttpStatus.OK, response.getStatusCode());
        var page = response.getBody();
        assertNotNull(page);
        assertEquals(len / 2, page.getTotalElements());
        for (var item : page) {
            assertFalse(codes.toString().contains(item.getCode()));
        }
    }
}
