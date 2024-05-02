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
import jakarta.persistence.EntityManagerFactory;
import jakarta.validation.ValidationException;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
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
    public Transaction createTransaction(@NotNull User user, @NotNull Transaction transaction) throws ConflictException, NotFoundException {
        var jpaUser = findUser(user);
        var byCode = transactionRepo.findByUserAndCode(jpaUser, transaction.getCode());
        if (byCode.isPresent()) {
            throw new ConflictException("Transaction code already registered.");
        }

        var jpaTransaction = build(jpaUser, transaction, JpaTransaction::builder);
        jpaTransaction.validate(validator);

        jpaTransaction = transactionRepo.save(jpaTransaction);
        var period = periodOf(jpaTransaction);
        if (period != null) {
            var categories = jpaTransaction.getCategories().stream()
                .map(category -> (JpaCategory) category).collect(Collectors.toSet());
            updateCategoriesExpenses(jpaUser, categories, period, jpaTransaction.getCurrency());
            // update account balance & to_pay
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
    public Transaction updateTransaction(@NotNull User user, @NotNull String code, @NotNull Transaction transaction) throws ConflictException, NotFoundException {
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

        var jpaTransaction = build(jpaUser, transaction, () -> byCode.get().toBuilder());
        jpaTransaction.validate(validator);

        return transactionRepo.save(jpaTransaction);
    }

    private JpaTransaction build(@NotNull JpaUser user,
                                 @NotNull Transaction transaction,
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
        return builderSupplier.get()
            .code(transaction.getCode())
            .user(user)
            .account(account)
            .categories(new HashSet<>(categories))
            .description(transaction.getDescription())
            .currency(ObjectUtil.firstNotNull(transaction.getCurrency(), account.getCurrency()))
            .amount(transaction.getAmount())
            .dueAt(transaction.getDueAt())
            .completedAt(transaction.getCompletedAt())
            .build();
    }

    public DatePeriod periodOf(@NotNull JpaTransaction transaction) {
        var from = transaction.getCreatedAt().toLocalDate().withDayOfMonth(1);
        return new DatePeriod(from, from.plusMonths(1));
    }

    private void updateCategoriesExpenses(@NotNull JpaUser user,
                                          @NotNull Set<JpaCategory> categories,
                                          @NotNull DatePeriod period,
                                          @NotNull Currency currency) throws NotFoundException {
        for (JpaCategory category : categories) {
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
        var expenses = transactions.stream().map(Transaction::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        var categoryExpense = categoryExpenseRepo.findByUserAndPeriod(user, from, to).orElse(new JpaCategoryExpense());
        categoryExpense = categoryExpense.toBuilder()
            .user(user)
            .category(category)
            .fromDateTime(from)
            .toDateTime(to)
            .currency(currency)
            .amount(expenses)
            .build();
        categoryExpenseRepo.save(categoryExpense);
    }
}
