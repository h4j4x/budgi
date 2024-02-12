package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.category.ApiCategory;
import com.sp1ke.budgi.api.helper.AuthHelper;
import com.sp1ke.budgi.api.helper.RestResponsePage;
import com.sp1ke.budgi.api.user.repo.UserRepo;
import com.sp1ke.budgi.api.wallet.ApiWallet;
import com.sp1ke.budgi.api.wallet.WalletType;
import com.sp1ke.budgi.api.wallet.domain.JpaWallet;
import com.sp1ke.budgi.api.wallet.repo.WalletRepo;
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
public class WalletControllerTests {
    private final UserRepo userRepo;

    private final WalletRepo walletRepo;

    private final PasswordEncoder passwordEncoder;

    private final RestClient restClient;

    @Autowired
    public WalletControllerTests(@LocalServerPort int port,
                                 UserRepo userRepo,
                                 WalletRepo walletRepo,
                                 PasswordEncoder passwordEncoder) {
        this.userRepo = userRepo;
        this.walletRepo = walletRepo;
        this.passwordEncoder = passwordEncoder;
        restClient = RestClient.builder()
            .baseUrl(String.format("http://localhost:%d/api/v1", port))
            .defaultHeader("Content-Type", MediaType.APPLICATION_JSON_VALUE)
            .build();
    }

    @BeforeEach
    void beforeEach() {
        walletRepo.deleteAll();
        userRepo.deleteAll();
    }

    @Test
    void createValidWithoutCodeReturnsCode() {
        var authTokenPair = AuthHelper.fetchAuthToken(userRepo, passwordEncoder, restClient);
        var wallet = ApiWallet.builder().name("Test").walletType(WalletType.CASH).build();

        var response = restClient.post()
            .uri("/wallet")
            .header("Authorization", "Bearer " + authTokenPair.getSecond())
            .body(wallet)
            .retrieve()
            .toEntity(ApiWallet.class);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        var apiWallet = response.getBody();
        assertNotNull(apiWallet);
        assertNotNull(apiWallet.getCode());
        assertEquals(wallet.getName(), apiWallet.getName());

        Optional<JpaWallet> byCode = walletRepo
            .findByUserIdAndCode(authTokenPair.getFirst(), apiWallet.getCode());
        assertTrue(byCode.isPresent());
        assertEquals(wallet.getName(), byCode.get().getName());
    }

    @Test
    void createValidWithCodeKeepsCode() {
        var authTokenPair = AuthHelper.fetchAuthToken(userRepo, passwordEncoder, restClient);
        var wallet = ApiWallet.builder()
            .code("test")
            .name("Test")
            .walletType(WalletType.CREDIT_CARD)
            .build();

        var response = restClient.post()
            .uri("/wallet")
            .header("Authorization", "Bearer " + authTokenPair.getSecond())
            .contentType(MediaType.APPLICATION_JSON)
            .accept(MediaType.APPLICATION_JSON)
            .body(wallet)
            .retrieve()
            .toEntity(ApiWallet.class);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        var apiWallet = response.getBody();
        assertNotNull(apiWallet);
        assertEquals(wallet.getCode(), apiWallet.getCode());
        assertEquals(wallet.getName(), apiWallet.getName());

        Optional<JpaWallet> byCode = walletRepo
            .findByUserIdAndCode(authTokenPair.getFirst(), apiWallet.getCode());
        assertTrue(byCode.isPresent());
        assertEquals(wallet.getName(), byCode.get().getName());
    }

    @Test
    void fetchPageReturnsUserItems() {
        var authTokenPair = AuthHelper.fetchAuthToken(userRepo, passwordEncoder, restClient);
        for (int i = 1; i < 9; i++) {
            var wallet = JpaWallet.builder()
                .userId(authTokenPair.getFirst() + i % 2)
                .code("test" + i)
                .name("Test " + i)
                .walletType(WalletType.CASH)
                .build();
            walletRepo.save(wallet);
        }

        var response = restClient.get()
            .uri("/wallet")
            .header("Authorization", "Bearer " + authTokenPair.getSecond())
            .retrieve()
            .toEntity(new ParameterizedTypeReference<RestResponsePage<ApiWallet>>() {
            });

        assertEquals(HttpStatus.OK, response.getStatusCode());
        var page = response.getBody();
        assertNotNull(page);
        assertEquals(4L, page.getTotalElements());
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
            var wallet = JpaWallet.builder()
                .userId(authTokenPair.getFirst())
                .code(code)
                .name("Test " + i)
                .walletType(WalletType.CASH)
                .build();
            walletRepo.save(wallet);
        }

        var response = restClient.get()
            .uri("/wallet?includingCodes=" + codes)
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
            var wallet = JpaWallet.builder()
                .userId(authTokenPair.getFirst())
                .code(code)
                .name("Test " + i)
                .walletType(WalletType.CASH)
                .build();
            walletRepo.save(wallet);
        }

        var response = restClient.get()
            .uri("/wallet?excludingCodes=" + codes)
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
