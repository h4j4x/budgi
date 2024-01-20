package com.sp1ke.budgi.api.common;

import jakarta.annotation.Nullable;
import jakarta.validation.constraints.NotNull;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface CrudService<T> {
    @NotNull
    default Page<T> fetch(@NotNull Long userId, @NotNull Pageable pageable) {
        return fetch(userId, pageable, null);
    }

    @NotNull
    Page<T> fetch(@NotNull Long userId, @NotNull Pageable pageable, @Nullable ApiFilter<T> filter);

    @NotNull
    T save(@NotNull Long userId, @NotNull T data, boolean throwIfExists);

    Optional<T> findByCode(@NotNull Long userId, @NotNull String code);

    void deleteByCode(@NotNull Long userId, @NotNull String code);

    void deleteByCodes(@NotNull Long userId, @NotNull String[] codes);
}
