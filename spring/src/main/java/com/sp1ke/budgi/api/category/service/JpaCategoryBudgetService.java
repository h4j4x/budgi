package com.sp1ke.budgi.api.category.service;

import com.sp1ke.budgi.api.category.ApiCategoryBudget;
import com.sp1ke.budgi.api.category.CategoryBudgetFilter;
import com.sp1ke.budgi.api.category.CategoryBudgetService;
import com.sp1ke.budgi.api.category.CategoryService;
import com.sp1ke.budgi.api.category.domain.JpaCategoryBudget;
import com.sp1ke.budgi.api.category.repo.CategoryBudgetRepo;
import com.sp1ke.budgi.api.common.ValidatorUtil;
import jakarta.annotation.Nullable;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;

@Service
@RequiredArgsConstructor
public class JpaCategoryBudgetService implements CategoryBudgetService {
    private final CategoryBudgetRepo categoryBudgetRepo;

    private final CategoryService categoryService;

    private final Validator validator;

    @Override
    public Page<ApiCategoryBudget> fetch(@NotNull Long userId, @NotNull Pageable pageable,
                                         @Nullable CategoryBudgetFilter filter) {
        var filterValue = filter != null ? filter : new CategoryBudgetFilter();
        var page = categoryBudgetRepo
            .findAllByUserIdAndFromDateAndToDate(userId, filterValue.fromDate(), filterValue.toDate(), pageable);
        return page.map(budget -> mapToApiCategoryBudget(userId, budget));
    }

    @Override
    public ApiCategoryBudget save(@NotNull Long userId, @NotNull ApiCategoryBudget data, boolean ignored) {
        var categoryId = categoryService.findIdByCode(userId, data.getCategoryCode());
        if (categoryId.isEmpty()) {
            throw new HttpClientErrorException(HttpStatus.BAD_REQUEST, "Invalid budget category");
        }
        var budget = categoryBudgetRepo
            .findByUserIdAndCode(userId, data.getCode())
            .orElse(new JpaCategoryBudget());
        budget = budget.toBuilder()
            .userId(userId)
            .code(data.getCode())
            .categoryId(categoryId.get())
            .currency(data.getCurrency())
            .amount(data.getAmount())
            .fromDate(data.getFromDate())
            .toDate(data.getToDate())
            .build();
        ValidatorUtil.validate(validator, budget);

        budget = categoryBudgetRepo.save(budget);
        return mapToApiCategoryBudget(userId, budget);
    }

    @Override
    public Optional<ApiCategoryBudget> findByCode(Long userId, String code) {
        var category = categoryBudgetRepo.findByUserIdAndCode(userId, code);
        return category.map(budget -> mapToApiCategoryBudget(userId, budget));
    }

    @Override
    public void deleteByCode(Long userId, String code) {
        categoryBudgetRepo.deleteByUserIdAndCode(userId, code);
    }

    @Override
    public void deleteByCodes(Long userId, @NotNull String[] codes) {
        categoryBudgetRepo.deleteByUserIdAndCodeIn(userId, codes);
    }

    @Override
    @NotNull
    public List<ApiCategoryBudget> categoryBudgets(@NotNull Long userId,
                                                   @NotNull OffsetDateTime from,
                                                   @NotNull OffsetDateTime to) {
        var fromDate = from.toLocalDate();
        var toDate = to.toLocalDate().plusDays(1);
        return categoryBudgetRepo
            .findAllByUserIdAndDatesBetween(userId, fromDate, toDate).stream()
            .map((JpaCategoryBudget budget) -> mapToApiCategoryBudget(userId, budget)).toList();
    }

    @NotNull
    private ApiCategoryBudget mapToApiCategoryBudget(@NotNull Long userId, @NotNull JpaCategoryBudget budget) {
        var category = categoryService.findById(userId, budget.getCategoryId()).orElse(null);
        return ApiCategoryBudget.builder()
            .code(budget.getCode())
            .categoryCode(category != null ? category.getCode() : null)
            .category(category)
            .currency(budget.getCurrency())
            .amount(budget.getAmount())
            .fromDate(budget.getFromDate())
            .toDate(budget.getToDate())
            .build();
    }
}
