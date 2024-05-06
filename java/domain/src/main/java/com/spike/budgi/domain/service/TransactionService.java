package com.spike.budgi.domain.service;

import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.error.NotFoundException;
import com.spike.budgi.domain.jpa.JpaTransaction;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.*;
import com.spike.budgi.domain.repo.AccountRepo;
import com.spike.budgi.domain.repo.TransactionRepo;
import com.spike.budgi.domain.repo.UserRepo;
import com.spike.budgi.util.ObjectUtil;
import jakarta.persistence.EntityManagerFactory;
import jakarta.validation.ValidationException;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Set;
import java.util.function.Supplier;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class TransactionService extends BaseService {
    private final AccountRepo accountRepo;

    private final CategoryService categoryService;

    private final TransactionRepo transactionRepo;

    private final Validator validator;

    private final EntityManagerFactory entityManagerFactory;

    public TransactionService(UserRepo userRepo, AccountRepo accountRepo, TransactionRepo transactionRepo,
                              CategoryService categoryService,
                              Validator validator, EntityManagerFactory entityManagerFactory) {
        super(userRepo);
        this.accountRepo = accountRepo;
        this.categoryService = categoryService;
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
        return updateAssociated(jpaTransaction);
    }

    @NotNull
    private JpaTransaction updateAssociated(@NotNull JpaTransaction transaction) throws NotFoundException {
        var period = transaction.datePeriod();
        for (var category : transaction.getCategories()) {
            updateCategoryExpenses(category, period, transaction);
        }
        return updateAccountBalance(transaction);
    }

    @NotNull
    public List<Transaction> findTransactions(@NotNull User user, TransactionFilter filter) throws NotFoundException {
        return _findTransactions(user, filter).stream()
            .map(jpaTransaction -> (Transaction) jpaTransaction)
            .toList();
    }

    @NotNull
    public List<JpaTransaction> _findTransactions(@NotNull User user,
                                                  TransactionFilter filter) throws NotFoundException {
        var jpaUser = findUser(user);
        try (var entityManager = entityManagerFactory.createEntityManager()) {
            var builder = entityManager.getCriteriaBuilder();
            var query = builder.createQuery(JpaTransaction.class);
            var root = query.from(JpaTransaction.class);

            var where = builder.equal(root.get("user"), jpaUser);
            if (filter.account() != null) {
                var account = accountRepo.findByUserAndCode(jpaUser, filter.account().getCode())
                    .orElseThrow(() -> new NotFoundException("Invalid account."));
                where = builder.and(where, builder.equal(root.get("account"), account));
            }
            if (filter.category() != null) {
                var categories = root.join("categories");
                var categoryWhere = builder.equal(categories.get("code"), filter.category().getCode());
                where = builder.and(where, categoryWhere);
            }
            if (filter.from() != null) {
                where = builder.and(where, builder.greaterThanOrEqualTo(root.get("dateTime"), filter.from()));
            }
            if (filter.to() != null) {
                where = builder.and(where, builder.lessThan(root.get("dateTime"), filter.to()));
            }

            query = query.select(root)
                .distinct(true)
                .orderBy(builder.asc(root.get("dateTime")))
                .where(where);
            return entityManager.createQuery(query).getResultList();
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

        var jpaTransaction = build(jpaUser, transaction, () -> byCode.get().toBuilder());
        jpaTransaction.validate(validator);

        jpaTransaction = transactionRepo.save(jpaTransaction);
        return updateAssociated(jpaTransaction);
    }

    @NotNull
    public Transaction createTransfer(@NotNull User user,
                                      @NotNull Account source,
                                      @NotNull Account target,
                                      @NotNull Set<Category> categories,
                                      @NotNull String description,
                                      @NotNull BigDecimal amount) throws NotFoundException {
        var jpaUser = findUser(user);
        var jpaCategories = categoryService.jpaCategories(jpaUser, categories);
        var builder = JpaTransaction.builder()
            .user(jpaUser)
            .categories(jpaCategories)
            .description(description)
            .currency(source.getCurrency());

        var accountSource = accountRepo.findByUserAndCode(jpaUser, source.getCode())
            .orElseThrow(() -> new NotFoundException("Source account is not valid."));
        var sourceTransaction = builder.account(accountSource).amount(amount.negate()).build();
        sourceTransaction.validate(validator);
        sourceTransaction = transactionRepo.save(sourceTransaction);
        sourceTransaction = updateAssociated(sourceTransaction);

        var accountTarget = accountRepo.findByUserAndCode(jpaUser, target.getCode())
            .orElseThrow(() -> new NotFoundException("Target account is not valid."));
        var targetTransaction = builder.account(accountTarget).amount(amount).transfer(sourceTransaction).build();
        targetTransaction.validate(validator);
        targetTransaction = transactionRepo.save(targetTransaction);
        targetTransaction = updateAssociated(targetTransaction);

        sourceTransaction.setTransfer(targetTransaction);
        return transactionRepo.save(sourceTransaction);
    }

    private JpaTransaction build(@NotNull JpaUser user,
                                 @NotNull Transaction transaction,
                                 @NotNull Supplier<JpaTransaction.JpaTransactionBuilder<?, ?>> builderSupplier) throws NotFoundException {
        if (transaction.getAccount() == null) {
            throw new ValidationException("Transaction account is required.");
        }
        var account = accountRepo.findByUserAndCode(user, transaction.getAccount().getCode())
            .orElseThrow(() -> new NotFoundException("Transaction account is not valid."));
        var categories = categoryService.jpaCategories(user, transaction.getCategories());
        return builderSupplier.get()
            .code(transaction.getCode())
            .user(user)
            .account(account)
            .categories(categories)
            .description(transaction.getDescription())
            .currency(ObjectUtil.firstNotNull(transaction.getCurrency(), account.getCurrency()))
            .amount(transaction.getAmount())
            .dateTime(transaction.getDateTime())
            .build();
    }

    @NotNull
    private JpaTransaction updateAccountBalance(@NotNull JpaTransaction saved) throws NotFoundException {
        var toDateTime = saved.getDateTime().truncatedTo(ChronoUnit.SECONDS);
        var date = transactionRepo.findPreviousDateTimeTo(saved.getUser(), toDateTime).orElse(toDateTime);
        var account = saved.getAccount();
        var filter = TransactionFilter.of(date, OffsetDateTime.now(), account);
        var transactions = _findTransactions(saved.getUser(), filter);
        log.debug("Found {} transactions to update account balance of transaction {} with datetime {}",
            transactions.size(), saved.getCode(), toDateTime);

        BigDecimal balance = null;
        for (var transaction : transactions) {
            if (balance == null) {
                if (transaction.getCode().equals(saved.getCode())) {
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

        account.setBalance(balance);
        accountRepo.save(account);

        return transactionRepo.findByUserAndCode(saved.getUser(), saved.getCode()).orElse(saved);
    }

    private void updateCategoryExpenses(@NotNull Category category,
                                        @NotNull DatePeriod period,
                                        @NotNull JpaTransaction saved) throws NotFoundException {
        var filter = TransactionFilter.of(period, category);
        var transactions = findTransactions(saved.getUser(), filter);
        var income = BigDecimal.ZERO;
        var outcome = BigDecimal.ZERO;
        for (var transaction : transactions) {
            if (transaction.getAmount().compareTo(BigDecimal.ZERO) < 0) {
                outcome = outcome.add(transaction.getAmount());
            } else {
                income = income.add(transaction.getAmount());
            }
        }
        categoryService.updateCategoryExpense(saved.getUser(), category, period, saved.getCurrency(), income, outcome);
    }
}
