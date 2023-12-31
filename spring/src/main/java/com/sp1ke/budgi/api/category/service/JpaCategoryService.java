package com.sp1ke.budgi.api.category.service;

import com.sp1ke.budgi.api.category.ApiCategory;
import com.sp1ke.budgi.api.category.CategoryService;
import com.sp1ke.budgi.api.category.domain.JpaCategory;
import com.sp1ke.budgi.api.category.repo.CategoryRepo;
import com.sp1ke.budgi.api.common.StringUtil;
import com.sp1ke.budgi.api.common.ValidatorUtil;
import jakarta.validation.Validator;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;

@Service
@RequiredArgsConstructor
public class JpaCategoryService implements CategoryService {
    private final CategoryRepo categoryRepo;

    private final Validator validator;

    @Override
    @NonNull
    public Page<ApiCategory> fetch(@NonNull Long userId, @NonNull Pageable pageable) {
        var page = categoryRepo.findAllByUserId(userId, pageable);
        return page.map(this::mapToApiCategory);
    }

    @Override
    @NonNull
    public ApiCategory save(@NonNull Long userId, @NonNull ApiCategory data, boolean throwIfExists) {
        var code = data.getCode() != null ? data.getCode() : StringUtil.randomString(6);
        var category = categoryRepo
            .findByUserIdAndCode(userId, code)
            .orElse(new JpaCategory());
        if (throwIfExists && category.getId() != null) {
            throw new HttpClientErrorException(HttpStatus.CONFLICT, "Category code already exists");
        }
        category = category.toBuilder()
            .userId(userId)
            .code(code)
            .name(data.getName())
            .build();
        ValidatorUtil.validate(validator, category);

        category = categoryRepo.save(category);
        return mapToApiCategory(category);
    }

    @Override
    public Optional<ApiCategory> findByCode(@NonNull Long userId, @NonNull String code) {
        var category = categoryRepo.findByUserIdAndCode(userId, code);
        return category.map(this::mapToApiCategory);
    }

    @Override
    public void deleteByCode(@NonNull Long userId, @NonNull String code) {
        categoryRepo.deleteByUserIdAndCode(userId, code);
    }

    @NonNull
    private ApiCategory mapToApiCategory(@NonNull JpaCategory category) {
        return ApiCategory.builder()
            .code(category.getCode())
            .name(category.getName())
            .build();
    }
}
