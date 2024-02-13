package com.sp1ke.budgi.api.wallet.repo;

import com.sp1ke.budgi.api.wallet.domain.JpaWalletBalance;
import java.time.LocalDate;
import java.util.Currency;
import java.util.List;
import java.util.Optional;
import org.springframework.data.repository.CrudRepository;

public interface WalletBalanceRepo extends CrudRepository<JpaWalletBalance, Long> {
    Optional<JpaWalletBalance> findOneByUserIdAndWalletIdAndCurrencyAndFromDateAndToDate(Long userId,
                                                                                         Long walletId,
                                                                                         Currency currency,
                                                                                         LocalDate fromDate,
                                                                                         LocalDate toDate);

    List<JpaWalletBalance> findAllByUserIdAndCurrency(Long userId, Currency currency);
}
