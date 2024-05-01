package com.spike.budgi.domain.service;

import com.spike.budgi.domain.TestApplication;
import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.error.NotFoundException;
import com.spike.budgi.domain.jpa.JpaAccount;
import com.spike.budgi.domain.jpa.JpaTransaction;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.AccountType;
import com.spike.budgi.domain.repo.AccountRepo;
import com.spike.budgi.domain.repo.TransactionRepo;
import com.spike.budgi.domain.repo.UserRepo;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.Currency;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import static com.spike.budgi.domain.TestApplication.assertBigDecimalEquals;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class TransactionServiceTests {
    final UserRepo userRepo;

    final AccountRepo accountRepo;

    final TransactionRepo transactionRepo;

    final TransactionService transactionService;

    @Autowired
    public TransactionServiceTests(UserRepo userRepo, AccountRepo accountRepo, TransactionRepo transactionRepo,
                                   TransactionService transactionService) {
        this.userRepo = userRepo;
        this.accountRepo = accountRepo;
        this.transactionRepo = transactionRepo;
        this.transactionService = transactionService;
    }

    @BeforeEach
    void beforeEach() {
        transactionRepo.deleteAll();
        accountRepo.deleteAll();
        userRepo.deleteAll();
    }

    @Test
    void contextLoad() {
        assertNotNull(userRepo);
        assertNotNull(accountRepo);
        assertNotNull(transactionRepo);
        assertNotNull(transactionService);
    }

    @Test
    void testCreateValidTransaction() throws ConflictException, NotFoundException {
        var user = TestApplication.createUser(userRepo);
        var account = createAccount(user);

        var inTransaction = JpaTransaction.builder()
            .code("test")
            .account(account)
            .description("Test")
            .amount(BigDecimal.TEN)
            .build();
        var savedTransaction = transactionService.createTransaction(user, inTransaction);
        assertNotNull(savedTransaction.getCreatedAt());
        assertNotNull(savedTransaction.getAccount());
        assertEquals(inTransaction.getCode(), savedTransaction.getCode());
        assertEquals(inTransaction.getDescription(), savedTransaction.getDescription());
        assertEquals(account.getCode(), savedTransaction.getAccount().getCode());
        assertEquals(account.getCurrency(), savedTransaction.getCurrency());
        assertBigDecimalEquals(inTransaction.getAmount(), savedTransaction.getAmount());

        var repoTransaction = transactionRepo.findByUserAndCode(user, inTransaction.getCode()).orElseThrow();
        assertEquals(inTransaction.getCode(), repoTransaction.getCode());
        assertEquals(inTransaction.getDescription(), repoTransaction.getDescription());
        assertEquals(account.getCurrency(), repoTransaction.getCurrency());
        assertBigDecimalEquals(inTransaction.getAmount(), repoTransaction.getAmount());

        var transactions = transactionService.findTransactions(user, null, null);
        assertFalse(transactions.isEmpty());
        assertEquals(1, transactions.size());
        var first = transactions.getFirst();
        assertEquals(inTransaction.getCode(), first.getCode());
        assertEquals(inTransaction.getDescription(), first.getDescription());
        assertEquals(account.getCurrency(), first.getCurrency());
        assertBigDecimalEquals(inTransaction.getAmount(), first.getAmount());
    }

    @NotNull
    private JpaAccount createAccount(@NotNull JpaUser user) {
        var account = JpaAccount.builder()
            .code("test")
            .user(user)
            .label("Test")
            .description("Test")
            .accountType(AccountType.CASH)
            .currency(Currency.getInstance("USD"))
            .quota(BigDecimal.ZERO)
            .toPay(BigDecimal.ZERO)
            .build();
        return accountRepo.save(account);
    }
}
