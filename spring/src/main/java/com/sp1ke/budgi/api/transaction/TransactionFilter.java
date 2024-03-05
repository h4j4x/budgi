package com.sp1ke.budgi.api.transaction;

import com.sp1ke.budgi.api.common.ApiFilter;
import com.sp1ke.budgi.api.common.DateTimeUtil;
import com.sp1ke.budgi.api.common.ObjectUtil;
import com.sp1ke.budgi.api.common.StringUtil;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.*;
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
        categoryCode = map.get("categoryCode");
        walletCode = map.get("walletCode");
        from = DateTimeUtil.parseLocalDate(ObjectUtil.<String>firstNonNull(map.get("from"), map.get("fromDate")));
        to = DateTimeUtil.parseLocalDate(map.get("to"));
    }

    public boolean hasInvalidDates() {
        return from == null || to == null || from.isAfter(to);
    }

    @Override
    public boolean isEmpty() {
        return super.isEmpty() &&
            (transactionTypes == null || transactionTypes.isEmpty()) &&
            (transactionStatuses == null || transactionStatuses.isEmpty()) &&
            categoryCode == null && walletCode == null && from == null && to == null;
    }

    @Override
    public String toString() {
        var map = new HashMap<String, String>();
        if (transactionTypes != null && !transactionTypes.isEmpty()) {
            var joined = String.join(",", transactionTypes.stream().map(Enum::name).toList());
            map.put("transactionTypes", "[" + joined + "]");
        }
        if (transactionStatuses != null && !transactionStatuses.isEmpty()) {
            var joined = String.join(",", transactionStatuses.stream().map(Enum::name).toList());
            map.put("transactionStatuses", "[" + joined + "]");
        }
        if (StringUtil.isNotBlank(categoryCode)) {
            map.put("categoryCode", categoryCode);
        }
        if (StringUtil.isNotBlank(walletCode)) {
            map.put("walletCode", walletCode);
        }
        if (from != null) {
            map.put("from", from.toString());
        }
        if (to != null) {
            map.put("to", to.toString());
        }
        var joined = String.join(",", map.keySet().stream().map(key -> key + "=" + map.get(key)).toList());
        return "{" + joined + "}";
    }
}
