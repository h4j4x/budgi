package com.sp1ke.budgi.api.helper;

import com.sp1ke.budgi.api.category.domain.JpaCategory;
import com.sp1ke.budgi.api.wallet.domain.JpaWallet;
import jakarta.validation.constraints.NotNull;

public record CategoryWalletWrapper(@NotNull JpaCategory category,
                                    @NotNull JpaWallet wallet,
                                    @NotNull String userToken,
                                    @NotNull Long userId) {
}
