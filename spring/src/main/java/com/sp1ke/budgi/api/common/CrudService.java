package com.sp1ke.budgi.api.common;

import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.lang.NonNull;

public interface CrudService<T> {
    @NonNull
    Page<T> fetch(@NonNull Long userId, @NonNull Pageable pageable);

    @NonNull
    T save(@NonNull Long userId, @NonNull T data, boolean throwIfExists);

    Optional<T> findByCode(@NonNull Long userId, @NonNull String code);

    void deleteByCode(@NonNull Long userId, @NonNull String code);
}
