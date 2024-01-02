package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.category.ApiCategory;
import com.sp1ke.budgi.api.category.CategoryService;
import com.sp1ke.budgi.api.user.AuthUser;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(
    value = "/category",
    consumes = MediaType.APPLICATION_JSON_VALUE,
    produces = MediaType.APPLICATION_JSON_VALUE
)
@RequiredArgsConstructor
public class CategoryController {
    private final CategoryService categoryService;

    @GetMapping
    ResponseEntity<Page<ApiCategory>> list(@AuthenticationPrincipal AuthUser principal, Pageable pageable) {
        var page = categoryService.fetch(principal.userId(), pageable);
        return ResponseEntity.ok(page);
    }

    @PostMapping
    ResponseEntity<ApiCategory> create(@AuthenticationPrincipal AuthUser principal,
                                       @RequestBody ApiCategory category) {
        var apiCategory = categoryService.save(principal.userId(), category, true);
        return ResponseEntity.status(201).body(apiCategory);
    }

    @GetMapping("/{code}")
    ResponseEntity<ApiCategory> getByCode(@AuthenticationPrincipal AuthUser principal,
                                          @PathVariable String code) {
        var apiCategory = categoryService
            .findByCode(principal.userId(), code)
            .orElseThrow(() -> new EntityNotFoundException("Category code is not valid"));
        return ResponseEntity.ok(apiCategory);
    }

    @PutMapping("/{code}")
    ResponseEntity<ApiCategory> updateByCode(@AuthenticationPrincipal AuthUser principal,
                                             @PathVariable String code,
                                             @RequestBody ApiCategory category) {
        if (category.getCode() == null) {
            category.setCode(code);
        }
        var apiCategory = categoryService.save(principal.userId(), category, false);
        return ResponseEntity.status(200).body(apiCategory);
    }

    @DeleteMapping("/{code}")
    ResponseEntity<Void> deleteByCode(@AuthenticationPrincipal AuthUser principal,
                                      @PathVariable String code) {
        categoryService.deleteByCode(principal.userId(), code);
        return ResponseEntity.ok(null);
    }
}
