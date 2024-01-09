package com.sp1ke.budgi.api.common;

import jakarta.validation.constraints.NotNull;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface CrudService<T> {
    @NotNull
    Page<T> fetch(@NotNull Long userId, @NotNull Pageable pageable);

    @NotNull
    T save(@NotNull Long userId, @NotNull T data, boolean throwIfExists);

    Optional<T> findByCode(@NotNull Long userId, @NotNull String code);

    void deleteByCode(@NotNull Long userId, @NotNull String code);
}
