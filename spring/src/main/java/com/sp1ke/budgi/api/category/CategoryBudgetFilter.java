package com.sp1ke.budgi.api.category;

import com.sp1ke.budgi.api.common.ApiFilter;
import com.sp1ke.budgi.api.common.DateTimeUtil;
import com.sp1ke.budgi.api.common.ObjectUtil;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.Map;
import lombok.*;

@Builder
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CategoryBudgetFilter extends ApiFilter<ApiCategoryBudget> {
    private String categoryCode;

    private LocalDate from;

    private LocalDate to;

    @NotNull
    public static CategoryBudgetFilter parseMap(@NotNull Map<String, String> map) {
        var filter = new CategoryBudgetFilter();
        filter.parseFromMap(map);
        return filter;
    }

    @Override
    protected void parseFromMap(Map<String, String> map) {
        super.parseFromMap(map);
        categoryCode = map.get("categoryCode");
        from = DateTimeUtil.parseLocalDate(ObjectUtil.firstNonNull(map.get("from"), map.get("fromDate")));
        to = DateTimeUtil.parseLocalDate(ObjectUtil.firstNonNull(map.get("to"), map.get("toDate")));
    }

    @Override
    public boolean isEmpty() {
        return super.isEmpty() &&
            categoryCode == null && from == null && to == null;
    }

    @NotNull
    public LocalDate fromDate() {
        if (from != null) {
            return from;
        }
        var now = YearMonth.now();
        return now.atDay(1);
    }

    @NotNull
    public LocalDate toDate() {
        if (to != null) {
            return to;
        }
        var now = YearMonth.now();
        return now.atEndOfMonth();
    }
}
