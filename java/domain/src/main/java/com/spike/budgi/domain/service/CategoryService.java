package com.spike.budgi.domain.service;

import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.error.NotFoundException;
import com.spike.budgi.domain.jpa.JpaCategory;
import com.spike.budgi.domain.model.Category;
import com.spike.budgi.domain.model.User;
import com.spike.budgi.domain.repo.CategoryRepo;
import com.spike.budgi.domain.repo.UserRepo;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.function.Supplier;
import org.springframework.stereotype.Service;

@Service
public class CategoryService extends BaseService {
    private final CategoryRepo categoryRepo;

    private final Validator validator;

    public CategoryService(UserRepo userRepo, CategoryRepo categoryRepo, Validator validator) {
        super(userRepo);
        this.categoryRepo = categoryRepo;
        this.validator = validator;
    }

    @NotNull
    public Category createCategory(@NotNull User user, @NotNull Category category) throws ConflictException, NotFoundException {
        var jpaUser = findUser(user);
        var byCode = categoryRepo.findByUserAndCode(jpaUser, category.getCode());
        if (byCode.isPresent()) {
            throw new ConflictException("Category code already registered.");
        }

        var jpaCategory = build(category, JpaCategory::builder);
        jpaCategory.setUser(jpaUser);
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

        var jpaCategory = build(category, () -> byCode.get().toBuilder());
        jpaCategory.validate(validator);

        return categoryRepo.save(jpaCategory);
    }

    private JpaCategory build(@NotNull Category category,
                              @NotNull Supplier<JpaCategory.JpaCategoryBuilder<?, ?>> builderSupplier) {
        return builderSupplier.get()
            .code(category.getCode())
            .label(category.getLabel())
            .description(category.getDescription())
            .build();
    }
}
