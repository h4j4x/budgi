package com.spike.budgi.domain.service;

import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.error.NotFoundException;
import com.spike.budgi.domain.jpa.JpaCategory;
import com.spike.budgi.domain.jpa.JpaCategoryExpense;
import com.spike.budgi.domain.jpa.JpaTransaction;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.*;
import com.spike.budgi.domain.repo.*;
import com.spike.budgi.util.DateTimeUtil;
import com.spike.budgi.util.ObjectUtil;
import com.spike.budgi.util.StringUtil;
import jakarta.persistence.EntityManagerFactory;
import jakarta.validation.ValidationException;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.*;
import java.util.function.Supplier;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;

@Service
public class TransactionService extends BaseService {
    private final AccountRepo accountRepo;

    private final CategoryRepo categoryRepo;

    private final CategoryExpenseRepo categoryExpenseRepo;

    private final TransactionRepo transactionRepo;

    private final Validator validator;

    private final EntityManagerFactory entityManagerFactory;

    public TransactionService(UserRepo userRepo, AccountRepo accountRepo,
                              CategoryRepo categoryRepo, CategoryExpenseRepo categoryExpenseRepo,
                              TransactionRepo transactionRepo,
                              Validator validator, EntityManagerFactory entityManagerFactory) {
        super(userRepo);
        this.accountRepo = accountRepo;
        this.categoryRepo = categoryRepo;
        this.categoryExpenseRepo = categoryExpenseRepo;
        this.transactionRepo = transactionRepo;
        this.validator = validator;
        this.entityManagerFactory = entityManagerFactory;
    }

    @NotNull
    public Transaction createTransaction(@NotNull User user, @NotNull Transaction transaction,
                                         DeferredMode deferredMode) throws ConflictException, NotFoundException {
        if (deferredMode == null || deferredMode.months() < 2) {
            return createTransaction(user, transaction);
        }

        Transaction root = null;
        JpaTransaction parent = null;
        var code = ObjectUtil.firstNotNull(transaction.getCode(), StringUtil.randomString(4));
        var amount = transaction.getAmount().divide(BigDecimal.valueOf(deferredMode.months()), RoundingMode.HALF_UP);
        var months = 1;
        while (months <= deferredMode.months()) {
            LocalDate dueAt;
            if (parent != null) {
                dueAt = parent.getDueAt().plusMonths(1);
            } else {
                var deferredStart = deferredMode.startDateTime();
                var paymentDay = transaction.getAccount().getPaymentDay();
                dueAt = DateTimeUtil.nextDayOfMonth(paymentDay, deferredStart.toLocalDate()).plusMonths(1);
            }
            var saved = createTransaction(user, transaction, code + "_" + months, amount, dueAt, parent);
            parent = (JpaTransaction) saved;
            if (root == null) {
                root = parent;
            }
            months += 1;
        }
        return root;
    }

    @NotNull
    public Transaction createTransaction(@NotNull User user, @NotNull Transaction transaction) throws ConflictException, NotFoundException {
        return createTransaction(user, transaction, null, null, null, null);
    }

    @NotNull
    private Transaction createTransaction(@NotNull User user, @NotNull Transaction transaction,
                                          String code, BigDecimal amount, LocalDate dueAt,
                                          JpaTransaction parent) throws ConflictException, NotFoundException {
        var jpaUser = findUser(user);
        var byCode = transactionRepo.findByUserAndCode(jpaUser, transaction.getCode());
        if (byCode.isPresent()) {
            throw new ConflictException("Transaction code already registered.");
        }

        var jpaTransaction = build(jpaUser, transaction, code, amount, dueAt, parent, JpaTransaction::builder);
        jpaTransaction.validate(validator);

        jpaTransaction = transactionRepo.save(jpaTransaction);
        updateAccountBalance(jpaUser, jpaTransaction.getCreatedAt());
        var period = periodOf(jpaTransaction);
        if (period != null) {
            var categories = jpaTransaction.getCategories().stream()
                .map(category -> (JpaCategory) category).collect(Collectors.toSet());
            updateCategoriesExpenses(jpaUser, categories, period, jpaTransaction.getCurrency());
        }
        return jpaTransaction;
    }

    @NotNull
    public List<Transaction> findTransactions(@NotNull User user, TransactionFilter filter) throws NotFoundException {
        var jpaUser = findUser(user);
        try (var entityManager = entityManagerFactory.createEntityManager()) {
            var builder = entityManager.getCriteriaBuilder();
            var query = builder.createQuery(JpaTransaction.class);
            var root = query.from(JpaTransaction.class);

            var where = builder.equal(root.get("user"), jpaUser);
            if (filter.from() != null) {
                where = builder.and(where, builder.greaterThanOrEqualTo(root.get("createdAt"), filter.from()));
            }
            if (filter.to() != null) {
                where = builder.and(where, builder.lessThan(root.get("createdAt"), filter.to()));
            }

            query = query.select(root)
                .distinct(true)
                .where(where);
            return entityManager.createQuery(query).getResultStream()
                .map(jpaTransaction -> (Transaction) jpaTransaction)
                .toList();
        }
    }

    @NotNull
    public Transaction updateTransaction(@NotNull User user, @NotNull String code,
                                         @NotNull Transaction transaction) throws ConflictException, NotFoundException {
        var jpaUser = findUser(user);
        var byCode = transactionRepo.findByUserAndCode(jpaUser, code);
        if (byCode.isEmpty()) {
            throw new NotFoundException("Transaction code is not valid.");
        }

        if (!code.equals(user.getCode())) {
            var duplicated = transactionRepo.findByUserAndCode(jpaUser, transaction.getCode());
            if (duplicated.isPresent()) {
                throw new ConflictException("Transaction code already registered.");
            }
        }

        var jpaTransaction = build(jpaUser, transaction,
            null, null, null, null, () -> byCode.get().toBuilder());
        jpaTransaction.validate(validator);

        return transactionRepo.save(jpaTransaction);
    }

    private JpaTransaction build(@NotNull JpaUser user,
                                 @NotNull Transaction transaction,
                                 String code, BigDecimal amount, LocalDate dueAt,
                                 JpaTransaction parent,
                                 @NotNull Supplier<JpaTransaction.JpaTransactionBuilder<?, ?>> builderSupplier) throws NotFoundException {
        if (transaction.getAccount() == null) {
            throw new ValidationException("Transaction account is required.");
        }
        var account = accountRepo.findByUserAndCode(user, transaction.getAccount().getCode())
            .orElseThrow(() -> new NotFoundException("Transaction account is not valid."));
        var categories = Collections.<Category>emptyList();
        if (transaction.getCategories() != null) {
            var categoriesCodes = transaction.getCategories().stream().map(Base::getCode).toList();
            categories = categoryRepo.findByUserAndCodeIn(user, categoriesCodes)
                .stream().map(category -> (Category) category).toList();
        }
        var builder = builderSupplier.get()
            .code(ObjectUtil.firstNotNull(code, transaction.getCode()))
            .user(user)
            .account(account)
            .categories(new HashSet<>(categories));
        if (parent != null) {
            builder.parent(parent);
        }
        return builder
            .description(transaction.getDescription())
            .currency(ObjectUtil.firstNotNull(transaction.getCurrency(), account.getCurrency()))
            .amount(ObjectUtil.firstNotNull(amount, transaction.getAmount()))
            .dueAt(ObjectUtil.firstNotNull(dueAt, transaction.getDueAt()))
            .completedAt(transaction.getCompletedAt())
            .build();
    }

    public DatePeriod periodOf(@NotNull JpaTransaction transaction) {
        var from = transaction.getCreatedAt().toLocalDate().withDayOfMonth(1);
        return new DatePeriod(from, from.plusMonths(1));
    }

    private void updateAccountBalance(@NotNull JpaUser user, @NotNull OffsetDateTime from) {
        var dateTime = transactionRepo.findPreviousCreatedAt(user, from).orElse(from);
        var transactions = transactionRepo.findByUserAndCreatedAtGreaterEqual(user, dateTime);
        BigDecimal balance = null;
        JpaTransaction last = null;
        for (var transaction : transactions) {
            last = transaction;
            if (balance == null) {
                if (dateTime.equals(from)) {
                    balance = BigDecimal.ZERO;
                } else {
                    balance = transaction.getAccountBalance();
                    continue;
                }
            }
            balance = balance.add(transaction.getAmount());
            transaction.setAccountBalance(balance);
        }
        transactionRepo.saveAll(transactions);

        if (last != null) {
            var account = last.getAccount();
            account.setBalance(balance);
            accountRepo.save(account);
        }
    }

    private void updateCategoriesExpenses(@NotNull JpaUser user,
                                          @NotNull Set<JpaCategory> categories,
                                          @NotNull DatePeriod period,
                                          @NotNull Currency currency) throws NotFoundException {
        for (var category : categories) {
            updateCategoryExpenses(user, category, period, currency);
        }
    }

    private void updateCategoryExpenses(@NotNull JpaUser user,
                                        @NotNull JpaCategory category,
                                        @NotNull DatePeriod period,
                                        @NotNull Currency currency) throws NotFoundException {
        var from = DateTimeUtil.toOffsetDateTime(period.from());
        var to = DateTimeUtil.toOffsetDateTime(period.to());
        var filter = TransactionFilter.of(from, to, category, true);
        var transactions = findTransactions(user, filter);
        var income = BigDecimal.ZERO;
        var outcome = BigDecimal.ZERO;
        for (var transaction : transactions) {
            if (transaction.getAmount().compareTo(BigDecimal.ZERO) < 0) {
                outcome = outcome.add(transaction.getAmount());
            } else {
                income = income.add(transaction.getAmount());
            }
        }
        var categoryExpense = categoryExpenseRepo.findByUserAndPeriod(user, from, to).orElse(new JpaCategoryExpense());
        categoryExpense = categoryExpense.toBuilder()
            .user(user)
            .category(category)
            .fromDateTime(from)
            .toDateTime(to)
            .currency(currency)
            .income(income)
            .outcome(outcome)
            .build();
        categoryExpenseRepo.save(categoryExpense);
    }
}
