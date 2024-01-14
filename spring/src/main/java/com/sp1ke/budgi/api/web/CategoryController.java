package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.category.ApiCategory;
import com.sp1ke.budgi.api.category.CategoryService;
import com.sp1ke.budgi.api.user.AuthUser;
import com.sp1ke.budgi.api.web.annot.ApiController;
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

    @GetMapping("/category")
    ResponseEntity<Page<ApiCategory>> list(@AuthenticationPrincipal AuthUser principal,
                                           @SortDefault(sort = "updatedAt", direction = Sort.Direction.DESC) Pageable pageable) {
        var itemsPage = categoryService.fetch(principal.userId(), pageable);
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
}
