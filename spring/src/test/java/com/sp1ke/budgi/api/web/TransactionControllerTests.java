package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.category.domain.JpaCategory;
import com.sp1ke.budgi.api.category.repo.CategoryRepo;
import com.sp1ke.budgi.api.helper.AssertHelper;
import com.sp1ke.budgi.api.helper.AuthHelper;
import com.sp1ke.budgi.api.helper.CategoryWalletWrapper;
import com.sp1ke.budgi.api.helper.RestResponsePage;
import com.sp1ke.budgi.api.transaction.ApiTransaction;
import com.sp1ke.budgi.api.transaction.TransactionType;
import com.sp1ke.budgi.api.transaction.TransactionsStats;
import com.sp1ke.budgi.api.transaction.domain.JpaTransaction;
import com.sp1ke.budgi.api.transaction.repo.TransactionRepo;
import com.sp1ke.budgi.api.user.repo.UserRepo;
import com.sp1ke.budgi.api.wallet.WalletType;
import com.sp1ke.budgi.api.wallet.domain.JpaWallet;
import com.sp1ke.budgi.api.wallet.repo.WalletRepo;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.Currency;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.modulith.test.ApplicationModuleTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.client.RestClient;
import static org.junit.jupiter.api.Assertions.*;

@ApplicationModuleTest(
    mode = ApplicationModuleTest.BootstrapMode.ALL_DEPENDENCIES,
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class TransactionControllerTests {
    final UserRepo userRepo;

    final CategoryRepo categoryRepo;

    final WalletRepo walletRepo;

    final TransactionRepo transactionRepo;

    final PasswordEncoder passwordEncoder;

    final RestClient restClient;

    @Autowired
    public TransactionControllerTests(@LocalServerPort int port,
                                      UserRepo userRepo,
                                      CategoryRepo categoryRepo,
                                      WalletRepo walletRepo,
                                      TransactionRepo transactionRepo,
                                      PasswordEncoder passwordEncoder) {
        this.userRepo = userRepo;
        this.categoryRepo = categoryRepo;
        this.walletRepo = walletRepo;
        this.transactionRepo = transactionRepo;
        this.passwordEncoder = passwordEncoder;
        restClient = RestClient.builder()
            .baseUrl(String.format("http://localhost:%d/api/v1", port))
            .defaultHeader("Content-Type", MediaType.APPLICATION_JSON_VALUE)
            .build();
    }

    @BeforeEach
    void beforeEach() {
        categoryRepo.deleteAll();
        walletRepo.deleteAll();
        userRepo.deleteAll();
        transactionRepo.deleteAll();
    }

    @Test
    void createValidWithoutCodeAndCurrencyAndDatetimeReturnsCodeAndCurrencyAndDatetime() {
        var authTokenPair = AuthHelper.fetchAuthToken(userRepo, passwordEncoder, restClient);

        var category = categoryRepo.save(JpaCategory.builder()
            .userId(authTokenPair.getFirst())
            .name("test")
            .build());
        var wallet = walletRepo.save(JpaWallet.builder()
            .userId(authTokenPair.getFirst())
            .name("test")
            .walletType(WalletType.CASH)
            .build());
        var transaction = ApiTransaction.builder()
            .categoryCode(category.getCode())
            .walletCode(wallet.getCode())
            .transactionType(TransactionType.INCOME)
            .amount(BigDecimal.valueOf(15.68))
            .description("test")
            .build();

        var response = restClient.post()
            .uri("/transaction")
            .header("Authorization", "Bearer " + authTokenPair.getSecond())
            .body(transaction)
            .retrieve()
            .toEntity(ApiTransaction.class);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        var apiTransaction = response.getBody();
        assertNotNull(apiTransaction);
        assertNotNull(apiTransaction.getCode());
        assertNotNull(apiTransaction.getCurrency());
        assertNotNull(apiTransaction.getDateTime());
        assertEquals(transaction.getTransactionType(), apiTransaction.getTransactionType());
        assertEquals(transaction.getAmount(), apiTransaction.getAmount());
        assertEquals(transaction.getDescription(), apiTransaction.getDescription());

        Optional<JpaTransaction> byCode = transactionRepo
            .findByUserIdAndCode(authTokenPair.getFirst(), apiTransaction.getCode());
        assertTrue(byCode.isPresent());
        assertEquals(apiTransaction.getTransactionType(), byCode.get().getTransactionType());
        assertEquals(apiTransaction.getCurrency(), byCode.get().getCurrency());
        AssertHelper.assertOffsetDateTimeEquals(apiTransaction.getDateTime(), byCode.get().getDateTime());
        assertEquals(apiTransaction.getAmount(), byCode.get().getAmount());
        assertEquals(apiTransaction.getDescription(), byCode.get().getDescription());
    }

    @Test
    void fetchPageReturnsUserItems() {
        var transactionTypeTimes = 9;
        var amount = BigDecimal.TEN;
        var dateTime = OffsetDateTime.now();
        var currency = Currency.getInstance("USD");
        var transactionType = TransactionType.INCOME;
        var categoryWalletWrapper =
            createTransactions(transactionTypeTimes, amount, dateTime, currency, new TransactionType[] {
                transactionType
            });
        var category = categoryWalletWrapper.category();
        var wallet = categoryWalletWrapper.wallet();

        var response = restClient.get()
            .uri("/transaction")
            .header("Authorization", "Bearer " + categoryWalletWrapper.userToken())
            .retrieve()
            .toEntity(new ParameterizedTypeReference<RestResponsePage<ApiTransaction>>() {
            });

        assertEquals(HttpStatus.OK, response.getStatusCode());
        var page = response.getBody();
        assertNotNull(page);
        assertEquals(transactionTypeTimes, page.getTotalElements());
        for (var transaction : page) {
            assertEquals(transactionType, transaction.getTransactionType());
            assertEquals(category.getCode(), transaction.getCategoryCode());
            assertEquals(wallet.getCode(), transaction.getWalletCode());
            assertEquals(currency, transaction.getCurrency());
            assertEquals(0, amount.compareTo(transaction.getAmount()));
            AssertHelper.assertOffsetDateTimeEquals(dateTime, transaction.getDateTime());
            assertEquals("test", transaction.getDescription());
        }
    }

    @Test
    void fetchPageReturnsUserItemsWithFilterTransactionType() {
        var transactionTypeTimes = 3;
        var amount = BigDecimal.TEN;
        var dateTime = OffsetDateTime.now();
        var currency = Currency.getInstance("USD");
        var categoryWalletWrapper =
            createTransactions(transactionTypeTimes, amount, dateTime, currency, TransactionType.values());
        var category = categoryWalletWrapper.category();
        var wallet = categoryWalletWrapper.wallet();

        var response = restClient.get()
            .uri("/transaction?transactionTypes=income")
            .header("Authorization", "Bearer " + categoryWalletWrapper.userToken())
            .retrieve()
            .toEntity(new ParameterizedTypeReference<RestResponsePage<ApiTransaction>>() {
            });

        assertEquals(HttpStatus.OK, response.getStatusCode());
        var page = response.getBody();
        assertNotNull(page);
        assertEquals(transactionTypeTimes, page.getTotalElements());
        for (var transaction : page) {
            assertEquals(TransactionType.INCOME, transaction.getTransactionType());
            assertEquals(category.getCode(), transaction.getCategoryCode());
            assertEquals(wallet.getCode(), transaction.getWalletCode());
            assertEquals(currency, transaction.getCurrency());
            assertEquals(0, amount.compareTo(transaction.getAmount()));
            AssertHelper.assertOffsetDateTimeEquals(dateTime, transaction.getDateTime());
            assertEquals("test", transaction.getDescription());
        }
    }

    @Test
    void fetchStats() {
        var transactionTypeTimes = 2;
        var amount = BigDecimal.TEN;
        var dateTime = OffsetDateTime.now();
        var currency = Currency.getInstance("USD");
        var categoryWalletWrapper =
            createTransactions(transactionTypeTimes, amount, dateTime, currency, TransactionType.values());

        var from = LocalDate.now().plusDays(-2);
        var to = LocalDate.now().plusDays(1);
        var response = restClient.get()
            .uri(String.format("/transaction/stats?from=%s&to=%s", from, to))
            .header("Authorization", "Bearer " + categoryWalletWrapper.userToken())
            .retrieve()
            .toEntity(TransactionsStats.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        var stats = response.getBody();
        assertNotNull(stats);
        assertEquals(from, stats.getFrom());
        assertEquals(to, stats.getTo());
        var expectedIncome = amount.multiply(BigDecimal.valueOf(transactionTypeTimes * 1.0)).stripTrailingZeros();
        assertEquals(expectedIncome, stats.getIncome().stripTrailingZeros());
    }

    private CategoryWalletWrapper createTransactions(int transactionTypeTimes, BigDecimal amount,
                                                     OffsetDateTime dateTime, Currency currency,
                                                     TransactionType[] transactionTypes) {
        assertNotNull(amount);
        assertNotNull(dateTime);
        assertNotNull(currency);
        assertNotNull(transactionTypes);
        assertTrue(transactionTypeTimes > 0);
        assertTrue(transactionTypes.length > 0);

        var authTokenPair = AuthHelper.fetchAuthToken(userRepo, passwordEncoder, restClient);
        var category = categoryRepo.save(JpaCategory.builder()
            .userId(authTokenPair.getFirst())
            .name("test")
            .build());
        var wallet = walletRepo.save(JpaWallet.builder()
            .userId(authTokenPair.getFirst())
            .name("test")
            .walletType(WalletType.CASH)
            .build());

        var listSize = transactionTypes.length * transactionTypeTimes;
        var transactionTypeIndex = 0;
        for (int i = 0; i < listSize; i++) {
            var transactionType = transactionTypes[transactionTypeIndex];
            var transaction = JpaTransaction.builder()
                .userId(authTokenPair.getFirst())
                .categoryId(category.getId())
                .walletId(wallet.getId())
                .transactionType(transactionType)
                .currency(currency)
                .amount(amount)
                .dateTime(dateTime)
                .description("test")
                .build();
            transactionRepo.save(transaction);
            transactionTypeIndex = (transactionTypeIndex + 1) % transactionTypes.length;
        }

        return new CategoryWalletWrapper(category, wallet, authTokenPair.getSecond());
    }
}
