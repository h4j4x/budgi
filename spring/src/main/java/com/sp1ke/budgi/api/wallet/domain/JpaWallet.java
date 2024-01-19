package com.sp1ke.budgi.api.wallet.domain;

import com.sp1ke.budgi.api.data.JpaUserBase;
import com.sp1ke.budgi.api.wallet.WalletType;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "wallets", indexes = {
    @Index(name = "wallets_user_id_code_UNQ", columnList = "userId, code", unique = true),
    @Index(name = "transactions_wallet_type_IDX", columnList = "walletType"),
})
@SuperBuilder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class JpaWallet extends JpaUserBase {
    @Size(min = 2, max = 100, message = "Valid wallet name is required (2 to 255 characters)")
    @NotNull(message = "Valid wallet name is required (2 to 255 characters)")
    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @NotNull(message = "Wallet type is required")
    @Column(name = "wallet_type", length = 50, nullable = false)
    private WalletType walletType;
}
