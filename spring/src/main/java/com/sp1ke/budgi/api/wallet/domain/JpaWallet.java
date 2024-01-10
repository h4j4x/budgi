package com.sp1ke.budgi.api.wallet.domain;

import com.sp1ke.budgi.api.wallet.WalletType;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.OffsetDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(name = "wallets", indexes = {
    @Index(name = "wallets_user_id_code_UNQ", columnList = "userId, code", unique = true)
})
@Builder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class JpaWallet {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Size(min = 2, max = 100, message = "Valid wallet code is required (2 to 100 characters)")
    @NotNull(message = "Valid wallet code is required (2 to 100 characters)")
    @Column(length = 100, nullable = false)
    private String code;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Size(min = 2, max = 100, message = "Valid wallet name is required (2 to 255 characters)")
    @NotNull(message = "Valid wallet name is required (2 to 255 characters)")
    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @NotNull(message = "Wallet type is required")
    @Column(name = "wallet_type", length = 50, nullable = false)
    private WalletType walletType;

    @CreationTimestamp
    @Column(updatable = false, name = "created_at")
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;
}
