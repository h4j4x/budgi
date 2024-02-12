package com.sp1ke.budgi.api.category;

import com.sp1ke.budgi.api.common.ApiFilter;
import jakarta.validation.constraints.NotNull;
import java.util.Map;

public class CategoryFilter extends ApiFilter<ApiCategory> {
    @NotNull
    public static CategoryFilter parseMap(@NotNull Map<String, String> map) {
        var filter = new CategoryFilter();
        filter.parseFromMap(map);
        return filter;
    }
}
