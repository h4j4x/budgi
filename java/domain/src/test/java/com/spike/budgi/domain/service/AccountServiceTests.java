package com.spike.budgi.domain.service;

import com.spike.budgi.domain.TestApplication;
import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.error.NotFoundException;
import com.spike.budgi.domain.jpa.JpaAccount;
import com.spike.budgi.domain.model.AccountType;
import com.spike.budgi.domain.repo.AccountRepo;
import com.spike.budgi.domain.repo.UserRepo;
import jakarta.validation.ValidationException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class AccountServiceTests {
    final UserRepo userRepo;

    final AccountRepo accountRepo;

    final AccountService accountService;

    @Autowired
    public AccountServiceTests(UserRepo userRepo, AccountRepo accountRepo, AccountService accountService) {
        this.userRepo = userRepo;
        this.accountRepo = accountRepo;
        this.accountService = accountService;
    }

    @BeforeEach
    void beforeEach() {
        accountRepo.deleteAll();
        userRepo.deleteAll();
    }

    @Test
    void contextLoad() {
        assertNotNull(userRepo);
        assertNotNull(accountRepo);
        assertNotNull(accountService);
    }

    @Test
    void testCreateValidAccount() throws ConflictException, NotFoundException {
        var user = TestApplication.createUser(userRepo);

        var inAccount = JpaAccount.builder()
            .code("test")
            .label("Test")
            .description("Test")
            .accountType(AccountType.CASH)
            .build();
        var savedAccount = accountService.createAccount(user, inAccount);
        assertNotNull(savedAccount.getCreatedAt());
        assertEquals(inAccount.getCode(), savedAccount.getCode());
        assertEquals(inAccount.getLabel(), savedAccount.getLabel());
        assertEquals(inAccount.getAccountType(), savedAccount.getAccountType());

        var repoAccount = accountRepo.findByUserAndCode(user, inAccount.getCode()).orElseThrow();
        assertNotNull(repoAccount.getCreatedAt());
        assertEquals(inAccount.getCode(), repoAccount.getCode());
        assertEquals(inAccount.getLabel(), repoAccount.getLabel());
        assertEquals(inAccount.getAccountType(), repoAccount.getAccountType());

        var categories = accountRepo.findByUser(user);
        assertFalse(categories.isEmpty());
        assertEquals(1, categories.size());
        var first = categories.getFirst();
        assertNotNull(first.getCreatedAt());
        assertEquals(inAccount.getCode(), first.getCode());
        assertEquals(inAccount.getLabel(), first.getLabel());
        assertEquals(inAccount.getAccountType(), first.getAccountType());
    }

    @Test
    void testUpdateAccount() throws ConflictException, NotFoundException {
        var user = TestApplication.createUser(userRepo);

        var inAccount = JpaAccount.builder()
            .code("test")
            .label("Test")
            .description("Test")
            .accountType(AccountType.CASH)
            .build();
        accountService.createAccount(user, inAccount);

        var requestAccount = inAccount.toBuilder()
            .code("updated")
            .label("Updated")
            .accountType(AccountType.DEBIT)
            .build();
        accountService.updateAccount(user, inAccount.getCode(), requestAccount);
        var updatedAccount = accountRepo.findByUserAndCode(user, inAccount.getCode());
        assertTrue(updatedAccount.isEmpty());
        updatedAccount = accountRepo.findByUserAndCode(user, requestAccount.getCode());
        assertTrue(updatedAccount.isPresent());
        assertEquals(requestAccount.getCode(), updatedAccount.get().getCode());
        assertEquals(requestAccount.getLabel(), updatedAccount.get().getLabel());
        assertEquals(requestAccount.getAccountType(), updatedAccount.get().getAccountType());

        var categories = accountRepo.findByUser(user);
        assertFalse(categories.isEmpty());
        assertEquals(1, categories.size());
        assertEquals(requestAccount.getCode(), categories.getFirst().getCode());
        assertEquals(requestAccount.getLabel(), categories.getFirst().getLabel());
        assertEquals(requestAccount.getAccountType(), categories.getFirst().getAccountType());
    }

    @Test
    void testCreateCreditAccountValidatesPaymentDay() {
        var user = TestApplication.createUser(userRepo);

        var account = JpaAccount.builder()
            .code("test")
            .label("Test")
            .description("Test")
            .accountType(AccountType.CREDIT)
            .build();
        var validationException = assertThrows(ValidationException.class,
            () -> accountService.createAccount(user, account));
        assertEquals("Account payment day is required for type credit.", validationException.getMessage());
    }
}
