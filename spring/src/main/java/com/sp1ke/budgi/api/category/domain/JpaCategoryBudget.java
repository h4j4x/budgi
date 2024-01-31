package com.sp1ke.budgi.api.category.domain;

import com.sp1ke.budgi.api.data.JpaUserAmountBase;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "categories_budgets", indexes = {
    @Index(name = "categories_budgets_category_id_IDX", columnList = "categoryId"),
    @Index(name = "categories_budgets_dates_IDX", columnList = "fromDate,toDate"),
})
@SuperBuilder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class JpaCategoryBudget extends JpaUserAmountBase {
    @Column(name = "category_id", nullable = false)
    private Long categoryId;

    @Column(name = "from_date", nullable = false)
    @NotNull(message = "Budget from date is required")
    private LocalDate fromDate;

    @Column(name = "to_date", nullable = false)
    @NotNull(message = "Budget to date is required")
    private LocalDate toDate;
}
