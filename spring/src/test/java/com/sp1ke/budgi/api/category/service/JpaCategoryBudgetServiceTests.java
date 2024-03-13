package com.sp1ke.budgi.api.category.service;

import com.sp1ke.budgi.api.category.CategoryBudgetFilter;
import com.sp1ke.budgi.api.category.domain.JpaCategoryBudget;
import com.sp1ke.budgi.api.category.repo.CategoryBudgetRepo;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Currency;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.Pageable;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class JpaCategoryBudgetServiceTests {
    final CategoryBudgetRepo budgetRepo;

    final JpaCategoryBudgetService budgetService;

    @Autowired
    public JpaCategoryBudgetServiceTests(CategoryBudgetRepo budgetRepo,
                                         JpaCategoryBudgetService budgetService) {
        this.budgetRepo = budgetRepo;
        this.budgetService = budgetService;
    }

    @BeforeEach
    void beforeEach() {
        budgetRepo.deleteAll();
    }

    @Test
    void testCountBudgets() {
        var len = 10;
        var userId = 1L;
        var currency = Currency.getInstance("USD");
        var fromDate = LocalDate.now().minusDays(2);
        var toDate = LocalDate.now().minusDays(1);
        for (var i = 1; i <= len; i++) {
            var budget = JpaCategoryBudget.builder()
                .userId(userId)
                .categoryId((long) i)
                .amount(BigDecimal.valueOf(i))
                .currency(currency)
                .fromDate(fromDate)
                .toDate(toDate)
                .build();
            budgetRepo.save(budget);
        }

        var filter = CategoryBudgetFilter.builder()
            .from(fromDate)
            .to(toDate)
            .build();
        var count = budgetService.count(userId, filter);
        assertEquals(len, count);
    }

    @Test
    void testCopyPreviousPeriod() {
        var len = 10;
        var userId = 1L;
        var currency = Currency.getInstance("USD");
        LocalDate previousFrom;
        LocalDate previousTo;
        for (var period = 4; period >= 1; period--) {
            previousFrom = LocalDate.now().minusDays(period);
            previousTo = previousFrom.plusDays(1);
            for (var i = 1; i <= len; i++) {
                var budget = JpaCategoryBudget.builder()
                    .userId(userId)
                    .categoryId((long) i)
                    .amount(BigDecimal.valueOf(i))
                    .currency(currency)
                    .fromDate(previousFrom)
                    .toDate(previousTo)
                    .build();
                budgetRepo.save(budget);
            }
        }

        var fromDate = LocalDate.now();
        var toDate = LocalDate.now().plusDays(1);
        var filter = CategoryBudgetFilter.builder()
            .from(fromDate)
            .to(toDate)
            .build();
        var count = budgetService.count(userId, filter);
        assertEquals(0, count);
        var page = budgetService.fetch(userId, Pageable.unpaged(), filter);
        assertTrue(page.isEmpty());

        budgetService.copyLastPeriod(userId, filter);
        count = budgetService.count(userId, filter);
        assertEquals(len, count);
        page = budgetService.fetch(userId, Pageable.unpaged(), filter);
        assertFalse(page.isEmpty());
        assertEquals(len, page.getSize());
        for (var budget : page) {
            assertEquals(fromDate, budget.getFromDate());
            assertEquals(toDate, budget.getToDate());
        }
    }
}
