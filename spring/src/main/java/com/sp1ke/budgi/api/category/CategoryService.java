package com.sp1ke.budgi.api.category;

import com.sp1ke.budgi.api.common.CrudService;
import jakarta.annotation.Nullable;
import jakarta.validation.constraints.NotNull;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

public interface CategoryService extends CrudService<ApiCategory, CategoryFilter> {
    Optional<Long> findIdByCode(@NotNull Long userId, @Nullable String code);

    Map<Long, String> fetchCodesOf(@NotNull Long userId, @NotNull Set<Long> ids);

    Optional<String> findCodeById(@NotNull Long userId, @NotNull Long id);
}
