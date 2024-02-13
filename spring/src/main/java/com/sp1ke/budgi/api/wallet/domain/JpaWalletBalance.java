package com.sp1ke.budgi.api.wallet.domain;

import com.sp1ke.budgi.api.data.JpaUserAmountBase;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "wallets_balances", indexes = {
    @Index(name = "wallets_balances_wallet_id_IDX", columnList = "walletId"),
    @Index(name = "wallets_balances_currency_IDX", columnList = "currency"),
    @Index(name = "wallets_balances_dates_IDX", columnList = "fromDate,toDate"),
})
@SuperBuilder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class JpaWalletBalance extends JpaUserAmountBase {
    @Column(name = "wallet_id", nullable = false)
    private Long walletId;

    @Column(name = "from_date", nullable = false)
    @NotNull(message = "Balance from date is required")
    private LocalDate fromDate;

    @Column(name = "to_date", nullable = false)
    @NotNull(message = "Balance to date is required")
    private LocalDate toDate;
}
