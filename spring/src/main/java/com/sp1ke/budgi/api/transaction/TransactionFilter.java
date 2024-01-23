package com.sp1ke.budgi.api.transaction;

import com.sp1ke.budgi.api.common.ApiFilter;
import com.sp1ke.budgi.api.common.DateTimeUtil;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class TransactionFilter extends ApiFilter<ApiTransaction> {
    private List<TransactionType> transactionTypes;

    private List<TransactionStatus> transactionStatuses;

    private String categoryCode;

    private String walletCode;

    private LocalDate from;

    private LocalDate to;

    @NotNull
    public static TransactionFilter parseMap(@NotNull Map<String, String> map) {
        var filter = new TransactionFilter();
        filter.parseFromMap(map);
        return filter;
    }

    @Override
    protected void parseFromMap(Map<String, String> map) {
        super.parseFromMap(map);
        if (map.containsKey("transactionTypes")) {
            var parts = map.get("transactionTypes").split(",");
            transactionTypes = Arrays.stream(parts)
                .map(TransactionType::parse)
                .filter(Objects::nonNull).toList();
        }
        if (map.containsKey("transactionStatuses")) {
            var parts = map.get("transactionStatuses").split(",");
            transactionStatuses = Arrays.stream(parts)
                .map(TransactionStatus::parse)
                .filter(Objects::nonNull).toList();
        }
        categoryCode = map.get("categoryId");
        walletCode = map.get("walletId");
        from = DateTimeUtil.parseLocalDate(map.get("from"));
        to = DateTimeUtil.parseLocalDate(map.get("to"));
    }

    @Override
    public boolean isEmpty() {
        return super.isEmpty() &&
            (transactionTypes == null || transactionTypes.isEmpty()) &&
            (transactionStatuses == null || transactionStatuses.isEmpty()) &&
            categoryCode == null && walletCode == null && from == null && to == null;
    }
}
