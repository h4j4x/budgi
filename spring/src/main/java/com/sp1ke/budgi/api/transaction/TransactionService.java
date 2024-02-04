package com.sp1ke.budgi.api.transaction;

import com.sp1ke.budgi.api.common.CrudService;
import jakarta.validation.constraints.NotNull;

public interface TransactionService extends CrudService<ApiTransaction, TransactionFilter> {
    @NotNull
    TransactionsStats stats(@NotNull Long userId, @NotNull TransactionFilter filter);
}
