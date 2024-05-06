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
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Collections;
import java.util.Currency;
import java.util.Set;
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
        assertNotNull(savedTransaction.getDateTime());
        assertEquals(1, savedTransaction.getCategories().size());
        var savedCategory = savedTransaction.getCategories().iterator().next();
        assertEquals(category.getCode(), savedCategory.getCode());
        assertEquals(inTransaction.getCode(), savedTransaction.getCode());
        assertEquals(inTransaction.getDescription(), savedTransaction.getDescription());
        assertBigDecimalEquals(inTransaction.getAmount(), savedTransaction.getAmount());
        assertEquals(account.getCode(), savedTransaction.getAccount().getCode());
        assertEquals(account.getCurrency(), savedTransaction.getCurrency());

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
    }

    @Test
    void testCreateTransaction_ThenUpdateAccountAndCategories() throws ConflictException, NotFoundException {
        var user = TestApplication.createUser(userRepo);
        var account = createAccount(user, AccountType.DEBIT);
        var category = createCategory(user);

        var amounts = new double[] {10, -5, -2, 15, -20};
        var balance = BigDecimal.ZERO;
        var income = BigDecimal.ZERO;
        var outcome = BigDecimal.ZERO;
        for (var amount : amounts) {
            BigDecimal theAmount = BigDecimal.valueOf(amount);
            var transaction = transactionService.createTransaction(user, JpaTransaction.builder()
                .code("trn" + amount)
                .account(account)
                .categories(Set.of(category))
                .description("Transaction" + amount)
                .amount(theAmount)
                .build());
            balance = balance.add(theAmount);
            if (amount < 0) {
                outcome = outcome.add(theAmount);
            } else {
                income = income.add(theAmount);
            }

            account = accountRepo.findByUserAndCode(user, account.getCode()).orElseThrow();
            assertBigDecimalEquals(balance, account.getBalance());

            var period = transaction.datePeriod();
            assertNotNull(period);
            var categoryExpense = categoryExpenseRepo.findByUserAndPeriod(user, period.fromDateTime(), period.toDateTime());
            assertTrue(categoryExpense.isPresent());
            assertEquals(transaction.getCurrency(), categoryExpense.get().getCurrency());
            assertBigDecimalEquals(income, categoryExpense.get().getIncome());
            assertBigDecimalEquals(outcome, categoryExpense.get().getOutcome());
        }
    }

    @Test
    void testCreateTransfer_ThenCreateTwoTransactions() throws NotFoundException {
        var user = TestApplication.createUser(userRepo);
        var sourceAccount = createAccount(user, AccountType.DEBIT);
        var targetAccount = createAccount(user, AccountType.CASH);

        var amount = BigDecimal.TEN;
        String description = "Transfer";
        var sourceTransaction = transactionService
            .createTransfer(user, sourceAccount, targetAccount, Collections.emptySet(), description, amount);
        assertEquals(description, sourceTransaction.getDescription());
        assertNotNull(sourceTransaction.getAccount());
        assertEquals(sourceAccount.getCode(), sourceTransaction.getAccount().getCode());
        assertBigDecimalEquals(amount, sourceTransaction.getAmount().negate());

        sourceAccount = accountRepo.findByUserAndCode(user, sourceAccount.getCode()).orElseThrow();
        assertBigDecimalEquals(amount.negate(), sourceAccount.getBalance());

        var targetTransaction = sourceTransaction.getTransfer();
        assertNotNull(targetTransaction);
        assertEquals(sourceTransaction, targetTransaction.getTransfer());
        assertEquals(description, targetTransaction.getDescription());
        assertNotNull(targetTransaction.getAccount());
        assertEquals(targetAccount.getCode(), targetTransaction.getAccount().getCode());
        assertBigDecimalEquals(amount, targetTransaction.getAmount());

        targetAccount = accountRepo.findByUserAndCode(user, targetAccount.getCode()).orElseThrow();
        assertBigDecimalEquals(amount, targetAccount.getBalance());
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
