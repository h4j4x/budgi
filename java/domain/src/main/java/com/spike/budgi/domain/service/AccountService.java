package com.spike.budgi.domain.service;

import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.error.NotFoundException;
import com.spike.budgi.domain.jpa.JpaAccount;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.Account;
import com.spike.budgi.domain.model.User;
import com.spike.budgi.domain.repo.AccountRepo;
import com.spike.budgi.domain.repo.UserRepo;
import com.spike.budgi.util.ObjectUtil;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;
import java.util.function.Supplier;
import org.springframework.stereotype.Service;

@Service
public class AccountService extends BaseService {
    private final AccountRepo accountRepo;

    private final ConfigService configService;

    private final Validator validator;

    public AccountService(UserRepo userRepo, AccountRepo accountRepo,
                          ConfigService configService, Validator validator) {
        super(userRepo);
        this.accountRepo = accountRepo;
        this.configService = configService;
        this.validator = validator;
    }

    @NotNull
    public Account createAccount(@NotNull User user, @NotNull Account account) throws ConflictException, NotFoundException {
        var jpaUser = findUser(user);
        var byCode = accountRepo.findByUserAndCode(jpaUser, account.getCode());
        if (byCode.isPresent()) {
            throw new ConflictException("Account code already registered.");
        }

        var jpaAccount = build(jpaUser, account, JpaAccount::builder);
        jpaAccount.validate(validator);

        return accountRepo.save(jpaAccount);
    }

    @NotNull
    public List<Account> findAccounts(@NotNull User user) throws NotFoundException {
        var jpaUser = findUser(user);
        return accountRepo.findByUser(jpaUser).stream().map(jpaAccount -> (Account) jpaAccount).toList();
    }

    @NotNull
    public Account updateAccount(@NotNull User user, @NotNull String code, @NotNull Account account) throws ConflictException, NotFoundException {
        var jpaUser = findUser(user);
        var byCode = accountRepo.findByUserAndCode(jpaUser, code);
        if (byCode.isEmpty()) {
            throw new NotFoundException("Account code is not valid.");
        }

        if (!code.equals(user.getCode())) {
            var duplicated = accountRepo.findByUserAndCode(jpaUser, account.getCode());
            if (duplicated.isPresent()) {
                throw new ConflictException("Account code already registered.");
            }
        }

        var jpaAccount = build(jpaUser, account, () -> byCode.get().toBuilder());
        jpaAccount.validate(validator);

        return accountRepo.save(jpaAccount);
    }

    private JpaAccount build(@NotNull JpaUser user,
                             @NotNull Account account,
                             @NotNull Supplier<JpaAccount.JpaAccountBuilder<?, ?>> builderSupplier) {
        return builderSupplier.get()
            .code(account.getCode())
            .user(user)
            .label(account.getLabel())
            .description(account.getDescription())
            .accountType(account.getAccountType())
            .currency(ObjectUtil.firstNotNull(account.getCurrency(), configService.defaultCurrency()))
            .quota(ObjectUtil.firstNotNull(account.getQuota(), BigDecimal.ZERO))
            .toPay(ObjectUtil.firstNotNull(account.getToPay(), BigDecimal.ZERO))
            .paymentDay(account.getPaymentDay())
            .build();
    }
}
