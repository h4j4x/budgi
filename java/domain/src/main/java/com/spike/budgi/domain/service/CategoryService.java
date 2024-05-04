package com.spike.budgi.domain.service;

import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.error.NotFoundException;
import com.spike.budgi.domain.jpa.JpaCategory;
import com.spike.budgi.domain.jpa.JpaCategoryExpense;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.Base;
import com.spike.budgi.domain.model.Category;
import com.spike.budgi.domain.model.DatePeriod;
import com.spike.budgi.domain.model.User;
import com.spike.budgi.domain.repo.CategoryExpenseRepo;
import com.spike.budgi.domain.repo.CategoryRepo;
import com.spike.budgi.domain.repo.UserRepo;
import com.spike.budgi.util.DateTimeUtil;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.*;
import java.util.function.Supplier;
import org.springframework.stereotype.Service;

@Service
public class CategoryService extends BaseService {
    private final CategoryRepo categoryRepo;

    private final CategoryExpenseRepo categoryExpenseRepo;

    private final Validator validator;

    public CategoryService(UserRepo userRepo, CategoryRepo categoryRepo, CategoryExpenseRepo categoryExpenseRepo,
                           Validator validator) {
        super(userRepo);
        this.categoryRepo = categoryRepo;
        this.categoryExpenseRepo = categoryExpenseRepo;
        this.validator = validator;
    }

    @NotNull
    public Category createCategory(@NotNull User user, @NotNull Category category) throws ConflictException, NotFoundException {
        var jpaUser = findUser(user);
        var byCode = categoryRepo.findByUserAndCode(jpaUser, category.getCode());
        if (byCode.isPresent()) {
            throw new ConflictException("Category code already registered.");
        }

        var jpaCategory = build(jpaUser, category, JpaCategory::builder);
        jpaCategory.validate(validator);

        return categoryRepo.save(jpaCategory);
    }

    @NotNull
    public List<Category> findCategories(@NotNull User user) throws NotFoundException {
        var jpaUser = findUser(user);
        return categoryRepo.findByUser(jpaUser).stream().map(jpaCategory -> (Category) jpaCategory).toList();
    }

    @NotNull
    public Category updateCategory(@NotNull User user, @NotNull String code, @NotNull Category category) throws ConflictException, NotFoundException {
        var jpaUser = findUser(user);
        var byCode = categoryRepo.findByUserAndCode(jpaUser, code);
        if (byCode.isEmpty()) {
            throw new NotFoundException("Category code is not valid.");
        }

        if (!code.equals(user.getCode())) {
            var duplicated = categoryRepo.findByUserAndCode(jpaUser, category.getCode());
            if (duplicated.isPresent()) {
                throw new ConflictException("Category code already registered.");
            }
        }

        var jpaCategory = build(jpaUser, category, () -> byCode.get().toBuilder());
        jpaCategory.validate(validator);

        return categoryRepo.save(jpaCategory);
    }

    private JpaCategory build(@NotNull JpaUser user,
                              @NotNull Category category,
                              @NotNull Supplier<JpaCategory.JpaCategoryBuilder<?, ?>> builderSupplier) {
        return builderSupplier.get()
            .code(category.getCode())
            .user(user)
            .label(category.getLabel())
            .description(category.getDescription())
            .build();
    }

    public void updateCategoryExpense(@NotNull JpaUser user,
                                      @NotNull JpaCategory category,
                                      @NotNull DatePeriod period,
                                      @NotNull Currency currency,
                                      @NotNull BigDecimal income,
                                      @NotNull BigDecimal outcome) {
        var categoryExpense = categoryExpenseRepo.findByUserAndPeriod(user, period.from(), period.to())
            .orElse(new JpaCategoryExpense());
        categoryExpense = categoryExpense.toBuilder()
            .user(user)
            .category(category)
            .fromDateTime(DateTimeUtil.toOffsetDateTime(period.from()))
            .toDateTime(DateTimeUtil.toOffsetDateTime(period.to()))
            .currency(currency)
            .income(income)
            .outcome(outcome)
            .build();
        categoryExpenseRepo.save(categoryExpense);
    }

    @NotNull
    Set<JpaCategory> jpaCategories(@NotNull JpaUser user, Set<Category> categories) {
        if (categories != null) {
            var categoriesCodes = categories.stream().map(Base::getCode).toList();
            return new HashSet<>(categoryRepo.findByUserAndCodeIn(user, categoriesCodes));
        }
        return Collections.emptySet();
    }

    @NotNull
    JpaCategory jpaCategory(@NotNull JpaUser jpaUser, @NotNull Category category) throws NotFoundException {
        return categoryRepo.findByUserAndCode(jpaUser, category.getCode())
            .orElseThrow(() -> new NotFoundException("Category not found"));
    }
}
