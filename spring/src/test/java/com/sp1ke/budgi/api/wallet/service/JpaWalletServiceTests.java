package com.sp1ke.budgi.api.wallet.service;

import com.sp1ke.budgi.api.common.SavedTransactionEvent;
import com.sp1ke.budgi.api.user.domain.JpaUser;
import com.sp1ke.budgi.api.user.repo.UserRepo;
import com.sp1ke.budgi.api.wallet.WalletType;
import com.sp1ke.budgi.api.wallet.domain.JpaWallet;
import com.sp1ke.budgi.api.wallet.repo.WalletBalanceRepo;
import com.sp1ke.budgi.api.wallet.repo.WalletRepo;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Currency;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.modulith.test.ApplicationModuleTest;
import org.springframework.modulith.test.Scenario;
import org.springframework.security.crypto.password.PasswordEncoder;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@ApplicationModuleTest(ApplicationModuleTest.BootstrapMode.ALL_DEPENDENCIES)
public class JpaWalletServiceTests {
    final WalletRepo walletRepo;

    final WalletBalanceRepo walletBalanceRepo;

    private final UserRepo userRepo;

    private final PasswordEncoder passwordEncoder;

    @Autowired
    public JpaWalletServiceTests(UserRepo userRepo,
                                 PasswordEncoder passwordEncoder,
                                 WalletRepo walletRepo,
                                 WalletBalanceRepo walletBalanceRepo) {
        this.userRepo = userRepo;
        this.passwordEncoder = passwordEncoder;
        this.walletRepo = walletRepo;
        this.walletBalanceRepo = walletBalanceRepo;
    }

    @BeforeEach
    void beforeEach() {
        walletBalanceRepo.deleteAll();
        walletRepo.deleteAll();
        userRepo.deleteAll();
    }

    @Test
    public void walletBalanceTransactionIntegration(Scenario scenario) {
        var password = "test";
        var user = userRepo.save(JpaUser.builder()
            .name("Test")
            .email("test@mail.com")
            .password(passwordEncoder.encode(password))
            .build());

        var wallet = walletRepo.save(JpaWallet.builder()
            .userId(user.getId())
            .name("test")
            .walletType(WalletType.CASH)
            .build());

        var currency = Currency.getInstance("USD");
        var event = new SavedTransactionEvent(user.getId(), wallet.getCode(),
            currency, OffsetDateTime.now(), BigDecimal.ONE.negate(), BigDecimal.TWO);
        scenario.publish(event)
            //.andWaitForStateChange(() -> walletBalanceRepo.findAllByUserIdAndCurrency(user.getId(), currency))
            .andWaitForStateChange(walletBalanceRepo::findAll)
            .andVerify(balances -> assertNotNull(balances)); // FIXME
    }
}
