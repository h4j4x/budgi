package com.sp1ke.budgi.api.category;

import com.sp1ke.budgi.api.common.CrudService;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public interface CategoryBudgetService extends CrudService<ApiCategoryBudget, CategoryBudgetFilter> {
    @NotNull
    List<ApiCategoryBudget> categoryBudgets(@NotNull Long userId, @NotNull CategoryBudgetFilter filter);

    void copyLastPeriod(@NotNull Long userId, @NotNull CategoryBudgetFilter filter);
}
