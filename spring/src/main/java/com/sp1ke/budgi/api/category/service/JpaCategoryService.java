package com.sp1ke.budgi.api.category.service;

import com.sp1ke.budgi.api.category.ApiCategory;
import com.sp1ke.budgi.api.category.CategoryFilter;
import com.sp1ke.budgi.api.category.CategoryService;
import com.sp1ke.budgi.api.category.domain.JpaCategory;
import com.sp1ke.budgi.api.category.repo.CategoryRepo;
import com.sp1ke.budgi.api.common.StringUtil;
import com.sp1ke.budgi.api.common.ValidatorUtil;
import com.sp1ke.budgi.api.data.JpaBase;
import jakarta.annotation.Nullable;
import jakarta.transaction.Transactional;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;

@Service
@RequiredArgsConstructor
public class JpaCategoryService implements CategoryService {
    private final CategoryRepo categoryRepo;

    private final Validator validator;

    @Override
    @NotNull
    public Page<ApiCategory> fetch(@NotNull Long userId, @NotNull Pageable pageable,
                                   @Nullable CategoryFilter filter) {
        var page = categoryRepo.findAllByUserId(userId, pageable);
        return page.map(this::mapToApiCategory);
    }

    @Override
    @NotNull
    public ApiCategory save(@NotNull Long userId, @NotNull ApiCategory data, boolean throwIfExists) {
        var category = categoryRepo
            .findByUserIdAndCode(userId, data.getCode())
            .orElse(new JpaCategory());
        if (throwIfExists && category.getId() != null) {
            throw new HttpClientErrorException(HttpStatus.CONFLICT, "Category code already exists");
        }
        category = category.toBuilder()
            .userId(userId)
            .code(data.getCode())
            .name(data.getName())
            .build();
        ValidatorUtil.validate(validator, category);

        category = categoryRepo.save(category);
        return mapToApiCategory(category);
    }

    @Override
    public Optional<ApiCategory> findByCode(@NotNull Long userId, @NotNull String code) {
        var category = categoryRepo.findByUserIdAndCode(userId, code);
        return category.map(this::mapToApiCategory);
    }

    @Override
    @Transactional
    public void deleteByCode(@NotNull Long userId, @NotNull String code) {
        categoryRepo.deleteByUserIdAndCode(userId, code);
    }

    @Override
    @Transactional
    public void deleteByCodes(@NotNull Long userId, @NotNull String[] codes) {
        categoryRepo.deleteByUserIdAndCodeIn(userId, codes);
    }

    @NotNull
    private ApiCategory mapToApiCategory(@NotNull JpaCategory category) {
        return ApiCategory.builder()
            .code(category.getCode())
            .name(category.getName())
            .build();
    }

    @Override
    public Optional<Long> findIdByCode(@NotNull Long userId, @Nullable String code) {
        if (StringUtil.isNotBlank(code)) {
            return categoryRepo.findByUserIdAndCode(userId, code)
                .map(JpaBase::getId);
        }
        return Optional.empty();
    }

    @Override
    public Map<Long, String> fetchCodesOf(@NotNull Long userId, @NotNull Set<Long> ids) {
        if (ids.isEmpty()) {
            return Collections.emptyMap();
        }
        var list = categoryRepo.findAllByUserIdAndIdIn(userId, ids);
        var map = new HashMap<Long, String>();
        for (var category : list) {
            map.put(category.getId(), category.getCode());
        }
        return map;
    }

    @Override
    public Optional<String> findCodeById(@NotNull Long userId, @NotNull Long id) {
        return categoryRepo.findByUserIdAndId(userId, id)
            .map(JpaBase::getCode);
    }
}
