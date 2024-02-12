package com.sp1ke.budgi.api.wallet;

import com.sp1ke.budgi.api.common.ApiFilter;
import jakarta.validation.constraints.NotNull;
import java.util.Map;

public class WalletFilter extends ApiFilter<ApiWallet> {
    @NotNull
    public static WalletFilter parseMap(@NotNull Map<String, String> map) {
        var filter = new WalletFilter();
        filter.parseFromMap(map);
        return filter;
    }
}
