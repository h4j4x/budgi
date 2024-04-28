package com.spike.budgi.domain.service;

import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.error.NotFoundException;
import com.spike.budgi.domain.jpa.JpaTransaction;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.Transaction;
import com.spike.budgi.domain.model.User;
import com.spike.budgi.domain.repo.AccountRepo;
import com.spike.budgi.domain.repo.TransactionRepo;
import com.spike.budgi.domain.repo.UserRepo;
import com.spike.budgi.util.ObjectUtil;
import jakarta.validation.ValidationException;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.List;
import java.util.function.Supplier;
import org.springframework.stereotype.Service;

@Service
public class TransactionService extends BaseService {
    private final AccountRepo accountRepo;

    private final TransactionRepo transactionRepo;

    private final Validator validator;

    public TransactionService(UserRepo userRepo, AccountRepo accountRepo, TransactionRepo transactionRepo,
                              Validator validator) {
        super(userRepo);
        this.accountRepo = accountRepo;
        this.transactionRepo = transactionRepo;
        this.validator = validator;
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

        return transactionRepo.save(jpaTransaction);
    }

    @NotNull
    public List<Transaction> findAccounts(@NotNull User user, OffsetDateTime from, OffsetDateTime to) throws NotFoundException {
        var jpaUser = findUser(user);
        return Collections.emptyList(); // TODO
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
        return builderSupplier.get()
            .code(transaction.getCode())
            .user(user)
            .account(account)
            .categories(Collections.emptySet()) // TODO
            .description(transaction.getDescription())
            .currency(ObjectUtil.firstNotNull(transaction.getCurrency(), account.getCurrency()))
            .amount(transaction.getAmount())
            .dueAt(transaction.getDueAt())
            .completedAt(transaction.getCompletedAt())
            .build();
    }
}
