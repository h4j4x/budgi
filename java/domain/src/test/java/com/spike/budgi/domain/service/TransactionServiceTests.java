package com.spike.budgi.domain.service;

import com.spike.budgi.domain.TestApplication;
import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.error.NotFoundException;
import com.spike.budgi.domain.jpa.JpaAccount;
import com.spike.budgi.domain.jpa.JpaCategory;
import com.spike.budgi.domain.jpa.JpaTransaction;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.AccountType;
import com.spike.budgi.domain.model.DeferredMode;
import com.spike.budgi.domain.model.TransactionFilter;
import com.spike.budgi.domain.repo.*;
import com.spike.budgi.util.DateTimeUtil;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
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
    void testCreateCashTransaction() throws ConflictException, NotFoundException {
        var user = TestApplication.createUser(userRepo);
        var account = createAccount(user, AccountType.CASH);
        var category = createCategory(user);

        var inTransaction = JpaTransaction.builder()
            .code("test")
            .account(account)
            .categories(Set.of(category))
            .description("Test")
            .amount(BigDecimal.TEN)
            .build();
        var savedTransaction = transactionService.createTransaction(user, inTransaction);
        assertNotNull(savedTransaction.getCreatedAt());
        assertNotNull(savedTransaction.getAccount());
        assertNotNull(savedTransaction.getDueAt());
        assertEquals(1, savedTransaction.getCategories().size());
        var savedCategory = savedTransaction.getCategories().iterator().next();
        assertEquals(category.getCode(), savedCategory.getCode());
        assertEquals(inTransaction.getCode(), savedTransaction.getCode());
        assertEquals(inTransaction.getDescription(), savedTransaction.getDescription());
        assertBigDecimalEquals(inTransaction.getAmount(), savedTransaction.getAmount());
        assertEquals(account.getCode(), savedTransaction.getAccount().getCode());
        assertEquals(account.getCurrency(), savedTransaction.getCurrency());
        assertEquals(DateTimeUtil.nextDayOfMonth(account.getPaymentDay()), savedTransaction.getDueAt());

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

        var period = repoTransaction.getDatePeriod();
        assertNotNull(period);
        var categoryExpense = categoryExpenseRepo.findByUserAndPeriod(user, period.from(), period.to());
        assertTrue(categoryExpense.isPresent());
        assertEquals(savedTransaction.getCurrency(), categoryExpense.get().getCurrency());
        assertBigDecimalEquals(savedTransaction.getAmount(), categoryExpense.get().getIncome());
        assertBigDecimalEquals(BigDecimal.ZERO, categoryExpense.get().getOutcome());
    }

    @Test
    void testCreateTransaction_ThenUpdateAccountBalance() throws ConflictException, NotFoundException {
        var user = TestApplication.createUser(userRepo);
        var account = createAccount(user, AccountType.DEBIT);

        var amounts = new double[] {10, -5, -2, 15, -20};
        var balance = .0;
        for (var amount : amounts) {
            transactionService.createTransaction(user, JpaTransaction.builder()
                .code("trn" + amount)
                .account(account)
                .categories(Collections.emptySet())
                .description("Transaction" + amount)
                .amount(BigDecimal.valueOf(amount))
                .build());
            balance += amount;

            account = accountRepo.findByUserAndCode(user, account.getCode()).orElseThrow();
            assertBigDecimalEquals(BigDecimal.valueOf(balance), account.getBalance());
        }
    }

    @Test
    void testCreateTransactionWithDeferredMode() throws ConflictException, NotFoundException {
        var user = TestApplication.createUser(userRepo);
        var account = createAccount(user, AccountType.CREDIT);
        var category = createCategory(user);

        var inTransaction = JpaTransaction.builder()
            .code("test")
            .account(account)
            .categories(Set.of(category))
            .description("Test")
            .amount(BigDecimal.valueOf(100))
            .build();
        var deferredMode = new DeferredMode(10, 1);
        var transaction = transactionService.createTransaction(user, inTransaction, deferredMode);
        assertNotNull(transaction);

        account = accountRepo.findByUserAndCode(user, account.getCode()).orElseThrow();
        assertBigDecimalEquals(BigDecimal.ZERO, account.getBalance());

        var expectedTransactionAmount = inTransaction.getAmount()
            .divide(BigDecimal.valueOf(deferredMode.months()), RoundingMode.HALF_UP);
        var balance = BigDecimal.ZERO;
        var paymentDay = account.getPaymentDay();
        var dueAt = DateTimeUtil.nextDayOfMonth(paymentDay, deferredMode.startDateTime().toLocalDate()).plusMonths(1);
        var transactionsCount = 0;
        do {
            transactionsCount += 1;
            assertTrue(transaction.getCode().endsWith("_" + transactionsCount));
            assertEquals(dueAt, transaction.getDueAt());
            assertBigDecimalEquals(expectedTransactionAmount, transaction.getAmount());

            var period = transaction.getDatePeriod();
            assertNotNull(period);
            var categoryExpense = categoryExpenseRepo.findByUserAndPeriod(user, period.from(), period.to());
            assertTrue(categoryExpense.isPresent());
            assertEquals(transaction.getCurrency(), categoryExpense.get().getCurrency());
            assertBigDecimalEquals(transaction.getAmount(), categoryExpense.get().getIncome());

            balance = balance.add(transaction.getAmount());
            transaction = transactionRepo.findByParent(transaction).orElse(null);
            dueAt = dueAt.plusMonths(1);
        } while (transaction != null && balance.compareTo(inTransaction.getAmount()) < 0);
        assertEquals(deferredMode.months(), transactionsCount);
        assertBigDecimalEquals(balance, inTransaction.getAmount());
    }

    @NotNull
    private JpaAccount createAccount(@NotNull JpaUser user, @NotNull AccountType accountType) {
        var account = JpaAccount.builder()
            .code("test" + System.currentTimeMillis())
            .user(user)
            .label("Test " + System.currentTimeMillis())
            .description("Test " + System.currentTimeMillis())
            .accountType(accountType)
            .currency(Currency.getInstance("USD"))
            .paymentDay((short) (LocalDate.now().getDayOfMonth() + 1))
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
