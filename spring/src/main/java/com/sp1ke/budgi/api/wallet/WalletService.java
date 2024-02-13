package com.sp1ke.budgi.api.wallet;

import com.sp1ke.budgi.api.common.CrudService;
import jakarta.annotation.Nullable;
import jakarta.validation.constraints.NotNull;
import java.util.*;

public interface WalletService extends CrudService<ApiWallet, WalletFilter> {
    Optional<Long> findIdByCode(@NotNull Long userId, @Nullable String code);

    Map<Long, ApiWallet> findAllByIds(@NotNull Long userId, @NotNull Set<Long> ids);

    Optional<ApiWallet> findById(@NotNull Long userId, @NotNull Long id);

    @NotNull
    List<ApiWallet> findAllByUserIdAndCodesIn(@NotNull Long userId, @NotNull Set<String> codes);

    @NotNull
    List<ApiWalletBalance> findAllBalanceByUserIdAndCurrency(@NotNull Long userId, @NotNull Currency currency);
}
