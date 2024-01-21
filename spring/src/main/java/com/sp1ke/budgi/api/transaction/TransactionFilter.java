package com.sp1ke.budgi.api.transaction;

import com.sp1ke.budgi.api.common.ApiFilter;
import jakarta.validation.constraints.NotNull;
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
    }

    @Override
    public boolean isEmpty() {
        return super.isEmpty() && (transactionTypes == null || transactionTypes.isEmpty());
    }
}
