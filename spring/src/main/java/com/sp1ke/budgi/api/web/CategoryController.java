package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.category.*;
import com.sp1ke.budgi.api.user.AuthUser;
import com.sp1ke.budgi.api.web.annot.ApiController;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.SortDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.HttpClientErrorException;

@ApiController
@RequiredArgsConstructor
public class CategoryController {
    private final CategoryService categoryService;

    private final CategoryBudgetService categoryBudgetService;

    @GetMapping("/category")
    ResponseEntity<Page<ApiCategory>> list(@AuthenticationPrincipal AuthUser principal,
                                           @SortDefault(sort = "updatedAt", direction = Sort.Direction.DESC) Pageable pageable,
                                           @RequestParam Map<String, String> params) {
        var filter = CategoryFilter.parseMap(params);
        var itemsPage = categoryService.fetch(principal.userId(), pageable, filter);
        return ResponseEntity.ok(itemsPage);
    }

    @PostMapping("/category")
    ResponseEntity<ApiCategory> create(@AuthenticationPrincipal AuthUser principal,
                                       @RequestBody ApiCategory category) {
        var apiCategory = categoryService.save(principal.userId(), category, true);
        return ResponseEntity.status(201).body(apiCategory);
    }

    @GetMapping("/category/{code}")
    ResponseEntity<ApiCategory> getByCode(@AuthenticationPrincipal AuthUser principal,
                                          @PathVariable String code) {
        var apiCategory = categoryService
            .findByCode(principal.userId(), code)
            .orElseThrow(() -> new HttpClientErrorException(HttpStatus.NOT_FOUND, "Category code is not valid"));
        return ResponseEntity.ok(apiCategory);
    }

    @PutMapping("/category/{code}")
    ResponseEntity<ApiCategory> updateByCode(@AuthenticationPrincipal AuthUser principal,
                                             @PathVariable String code,
                                             @RequestBody ApiCategory category) {
        if (category.getCode() == null) {
            category.setCode(code);
        }
        var apiCategory = categoryService.save(principal.userId(), category, false);
        return ResponseEntity.status(200).body(apiCategory);
    }

    @DeleteMapping("/category/{code}")
    ResponseEntity<Void> deleteByCode(@AuthenticationPrincipal AuthUser principal,
                                      @PathVariable String code) {
        categoryService.deleteByCode(principal.userId(), code);
        return ResponseEntity.ok(null);
    }

    @DeleteMapping("/category/batch")
    ResponseEntity<Void> deleteByCodes(@AuthenticationPrincipal AuthUser principal,
                                       @RequestParam String codes) {
        categoryService.deleteByCodes(principal.userId(), codes.split(","));
        return ResponseEntity.ok(null);
    }

    @GetMapping("/category-budget")
    ResponseEntity<Page<ApiCategoryBudget>> listBudgets(@AuthenticationPrincipal AuthUser principal,
                                                        @SortDefault(sort = "updatedAt", direction = Sort.Direction.DESC) Pageable pageable,
                                                        @RequestParam Map<String, String> params) {
        var filter = CategoryBudgetFilter.parseMap(params);
        var itemsPage = categoryBudgetService.fetch(principal.userId(), pageable, filter);
        return ResponseEntity.ok(itemsPage);
    }

    @PostMapping("/category-budget")
    ResponseEntity<ApiCategoryBudget> createBudget(@AuthenticationPrincipal AuthUser principal,
                                                   @RequestBody ApiCategoryBudget budget) {
        var apiCategoryBudget = categoryBudgetService.save(principal.userId(), budget, false);
        return ResponseEntity.status(201).body(apiCategoryBudget);
    }

    @GetMapping("/category-budget/{code}")
    ResponseEntity<ApiCategoryBudget> getBudgetByCode(@AuthenticationPrincipal AuthUser principal,
                                                      @PathVariable String code) {
        var apiCategoryBudget = categoryBudgetService
            .findByCode(principal.userId(), code)
            .orElseThrow(() -> new HttpClientErrorException(HttpStatus.NOT_FOUND, "Category Budget code is not valid"));
        return ResponseEntity.ok(apiCategoryBudget);
    }

    @GetMapping("/category-budget/count")
    ResponseEntity<Long> countBudgets(@AuthenticationPrincipal AuthUser principal,
                                         @RequestParam Map<String, String> params) {
        var filter = CategoryBudgetFilter.parseMap(params);
        var count = categoryBudgetService.count(principal.userId(), filter);
        return ResponseEntity.ok(count);
    }

    @PutMapping("/category-budget/{code}")
    ResponseEntity<ApiCategoryBudget> updateBudgetByCode(@AuthenticationPrincipal AuthUser principal,
                                                         @PathVariable String code,
                                                         @RequestBody ApiCategoryBudget budget) {
        if (budget.getCode() == null) {
            budget.setCode(code);
        }
        var apiCategoryBudget = categoryBudgetService.save(principal.userId(), budget, false);
        return ResponseEntity.status(200).body(apiCategoryBudget);
    }

    @DeleteMapping("/category-budget/{code}")
    ResponseEntity<Void> deleteBudgetByCode(@AuthenticationPrincipal AuthUser principal,
                                            @PathVariable String code) {
        categoryBudgetService.deleteByCode(principal.userId(), code);
        return ResponseEntity.ok(null);
    }

    @DeleteMapping("/category-budget/batch")
    ResponseEntity<Void> deleteBudgetsByCodes(@AuthenticationPrincipal AuthUser principal,
                                              @RequestParam String codes) {
        categoryBudgetService.deleteByCodes(principal.userId(), codes.split(","));
        return ResponseEntity.ok(null);
    }
}
