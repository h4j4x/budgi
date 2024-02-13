package com.sp1ke.budgi.api.category;

import com.sp1ke.budgi.api.common.CrudService;
import jakarta.annotation.Nullable;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

public interface CategoryService extends CrudService<ApiCategory, CategoryFilter> {
    Optional<Long> findIdByCode(@NotNull Long userId, @Nullable String code);

    @NotNull
    Map<Long, ApiCategory> findAllByIds(@NotNull Long userId, @NotNull Set<Long> ids);

    Optional<ApiCategory> findById(@NotNull Long userId, @NotNull Long id);

    @NotNull
    List<ApiCategory> findAllByUserIdAndCodesIn(@NotNull Long userId, @NotNull Set<String> codes);
}
