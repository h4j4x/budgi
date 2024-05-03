package com.spike.budgi.domain.service;

import com.spike.budgi.domain.TestApplication;
import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.error.NotFoundException;
import com.spike.budgi.domain.jpa.JpaAccount;
import com.spike.budgi.domain.jpa.JpaCategory;
import com.spike.budgi.domain.jpa.JpaTransaction;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.AccountType;
import com.spike.budgi.domain.model.TransactionFilter;
import com.spike.budgi.domain.repo.*;
import com.spike.budgi.util.DateTimeUtil;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.Currency;
import java.util.Set;
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

    final CategoryRepo categoryRepo;

    final CategoryExpenseRepo categoryExpenseRepo;

    final TransactionRepo transactionRepo;

    final TransactionService transactionService;

    @Autowired
    public TransactionServiceTests(UserRepo userRepo, AccountRepo accountRepo,
                                   CategoryRepo categoryRepo, CategoryExpenseRepo categoryExpenseRepo,
                                   TransactionRepo transactionRepo,
                                   TransactionService transactionService) {
        this.userRepo = userRepo;
        this.accountRepo = accountRepo;
        this.categoryRepo = categoryRepo;
        this.categoryExpenseRepo = categoryExpenseRepo;
        this.transactionRepo = transactionRepo;
        this.transactionService = transactionService;
    }

    @BeforeEach
    void beforeEach() {
        transactionRepo.deleteAll();
        categoryExpenseRepo.deleteAll();
        categoryRepo.deleteAll();
        accountRepo.deleteAll();
        userRepo.deleteAll();
    }

    @Test
    void contextLoad() {
        assertNotNull(userRepo);
        assertNotNull(categoryRepo);
        assertNotNull(categoryExpenseRepo);
        assertNotNull(accountRepo);
        assertNotNull(transactionRepo);
        assertNotNull(transactionService);
    }

    @Test
    void testCreateValidTransaction() throws ConflictException, NotFoundException {
        var user = TestApplication.createUser(userRepo);
        var account = createAccount(user);
        var category = createCategory(user);

        var inTransaction = JpaTransaction.builder()
            .code("test")
            .account(account)
            .categories(Set.of(category))
            .description("Test")
            .amount(BigDecimal.TEN)
            .completedAt(OffsetDateTime.now())
            .build();
        var savedTransaction = transactionService.createTransaction(user, inTransaction);
        assertNotNull(savedTransaction.getCreatedAt());
        assertNotNull(savedTransaction.getAccount());
        assertEquals(1, savedTransaction.getCategories().size());
        var savedCategory = savedTransaction.getCategories().iterator().next();
        assertEquals(category.getCode(), savedCategory.getCode());
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

        var transactions = transactionService.findTransactions(user, TransactionFilter.empty());
        assertFalse(transactions.isEmpty());
        assertEquals(1, transactions.size());
        var first = transactions.getFirst();
        assertEquals(inTransaction.getCode(), first.getCode());
        assertEquals(inTransaction.getDescription(), first.getDescription());
        assertEquals(account.getCurrency(), first.getCurrency());
        assertBigDecimalEquals(inTransaction.getAmount(), first.getAmount());

        var period = transactionService.periodOf(repoTransaction);
        assertNotNull(period);
        var from = DateTimeUtil.toOffsetDateTime(period.from());
        var to = DateTimeUtil.toOffsetDateTime(period.to());
        var categoryExpense = categoryExpenseRepo.findByUserAndPeriod(user, from, to);
        assertTrue(categoryExpense.isPresent());
        assertEquals(savedTransaction.getCurrency(), categoryExpense.get().getCurrency());
        assertBigDecimalEquals(savedTransaction.getAmount(), categoryExpense.get().getIncome());
        assertBigDecimalEquals(BigDecimal.ZERO, categoryExpense.get().getOutcome());
    }

    @Test
    void testTransactionUpdateAccountBalance() throws ConflictException, NotFoundException {
        var user = TestApplication.createUser(userRepo);
        var account = createAccount(user);

        var amounts = new double[] {10, -5, -2, 15, -20};
        var balance = .0;
        for (var amount : amounts) {
            transactionService.createTransaction(user, JpaTransaction.builder()
                .code("trn" + amount)
                .account(account)
                .categories(Collections.emptySet())
                .description("Transaction" + amount)
                .amount(BigDecimal.valueOf(amount))
                .completedAt(OffsetDateTime.now())
                .build());
            balance += amount;

            account = accountRepo.findByUserAndCode(user, account.getCode()).orElseThrow();
            assertBigDecimalEquals(BigDecimal.valueOf(balance), account.getBalance());
        }
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
            .build();
        return accountRepo.save(account);
    }

    @NotNull
    private JpaCategory createCategory(@NotNull JpaUser user) {
        var category = JpaCategory.builder()
            .code("test")
            .user(user)
            .label("Test")
            .description("Test")
            .build();
        return categoryRepo.save(category);
    }
}
