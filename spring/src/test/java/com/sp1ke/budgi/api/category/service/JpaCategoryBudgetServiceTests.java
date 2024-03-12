package com.sp1ke.budgi.api.category.service;

import com.sp1ke.budgi.api.category.domain.JpaCategoryBudget;
import com.sp1ke.budgi.api.category.repo.CategoryBudgetRepo;
import com.sp1ke.budgi.api.user.domain.JpaUser;
import com.sp1ke.budgi.api.user.repo.UserRepo;
import com.sp1ke.budgi.api.wallet.repo.WalletBalanceRepo;
import com.sp1ke.budgi.api.wallet.repo.WalletRepo;
import java.math.BigDecimal;
import java.util.Currency;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.modulith.test.ApplicationModuleTest;
import org.springframework.security.crypto.password.PasswordEncoder;

@ApplicationModuleTest(ApplicationModuleTest.BootstrapMode.ALL_DEPENDENCIES)
public class JpaCategoryBudgetServiceTests {
    final CategoryBudgetRepo budgetRepo;

    final JpaCategoryBudgetService budgetService;

    final UserRepo userRepo;

    final PasswordEncoder passwordEncoder;

    @Autowired
    public JpaCategoryBudgetServiceTests(UserRepo userRepo,
                                         PasswordEncoder passwordEncoder,
                                         CategoryBudgetRepo budgetRepo,
                                         JpaCategoryBudgetService budgetService) {
        this.userRepo = userRepo;
        this.passwordEncoder = passwordEncoder;
        this.budgetRepo = budgetRepo;
        this.budgetService = budgetService;
    }

    @BeforeEach
    void beforeEach() {
        budgetRepo.deleteAll();
        userRepo.deleteAll();
    }

    @Test
    void testCopyPreviousBudgets() {
        var len = 10;
        var userId = 1L;
        var currency = Currency.getInstance("USD");
        for (var i = 1; i <= len; i++) {
            var budget = JpaCategoryBudget.builder()
                .userId(userId)
                .categoryId((long) i)
                .amount(BigDecimal.valueOf(i))
                .currency(currency)
                .fromDate(previousFrom)
                .build();
            budgetRepo.save(budget);
        }
    }
}
