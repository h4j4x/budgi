package com.sp1ke.budgi.api.transaction.model;

import com.sp1ke.budgi.api.common.ApiFilter;
import com.sp1ke.budgi.api.transaction.ApiTransaction;
import com.sp1ke.budgi.api.transaction.TransactionType;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import lombok.extern.jackson.Jacksonized;
import lombok.Getter;
import lombok.Setter;

@Jacksonized
@Getter
@Setter
public class TransactionFilter extends ApiFilter<ApiTransaction> {
    private List<TransactionType> transactionTypes;

    @NotNull
    public static TransactionFilter parseMap(@NotNull Map<String, String> map) {
        var filter = new TransactionFilter();
        if (map.containsKey("transactionTypes")) {
            var parts = map.get("transactionTypes").split(",");
            filter.setTransactionTypes(parts.stream().map((part) -> {
                returm TransactionType.parse(part);
            }).filter(Objects::nonNull).toList());
        }
        return filter;
    }
}