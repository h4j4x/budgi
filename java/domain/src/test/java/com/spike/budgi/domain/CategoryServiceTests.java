package com.spike.budgi.domain;

import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.error.NotFoundException;
import com.spike.budgi.domain.jpa.JpaCategory;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.UserCodeType;
import com.spike.budgi.domain.repo.CategoryRepo;
import com.spike.budgi.domain.repo.UserRepo;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class CategoryServiceTests {
    final UserRepo userRepo;

    final CategoryRepo categoryRepo;

    final CategoryService categoryService;

    @Autowired
    public CategoryServiceTests(UserRepo userRepo, CategoryRepo categoryRepo, CategoryService categoryService) {
        this.userRepo = userRepo;
        this.categoryRepo = categoryRepo;
        this.categoryService = categoryService;
    }

    @BeforeEach
    void beforeEach() {
        categoryRepo.deleteAll();
        userRepo.deleteAll();
    }

    @Test
    void contextLoad() {
        assertNotNull(userRepo);
        assertNotNull(categoryRepo);
        assertNotNull(categoryService);
    }

    @Test
    void testCreateValidCategory() throws ConflictException, NotFoundException {
        var user = createUser();

        var inCategory = JpaCategory.builder()
            .code("test")
            .label("Test")
            .description("Test")
            .build();
        var savedCategory = categoryService.createCategory(user, inCategory);
        assertEquals(inCategory.getCode(), savedCategory.getCode());
        assertEquals(inCategory.getLabel(), savedCategory.getLabel());

        var repoCategory = categoryRepo.findByUserAndCode(user, inCategory.getCode()).orElseThrow();
        assertEquals(inCategory.getCode(), repoCategory.getCode());
        assertEquals(inCategory.getLabel(), repoCategory.getLabel());

        var categories = categoryRepo.findByUser(user);
        assertFalse(categories.isEmpty());
        assertEquals(1, categories.size());
        assertEquals(inCategory.getCode(), categories.getFirst().getCode());
        assertEquals(inCategory.getLabel(), categories.getFirst().getLabel());
    }

    @Test
    void testUpdateCategory() throws ConflictException, NotFoundException {
        var user = createUser();

        var inCategory = JpaCategory.builder()
            .code("test")
            .label("Test")
            .description("Test")
            .build();
        categoryService.createCategory(user, inCategory);

        var requestCategory = inCategory.toBuilder()
            .code("updated")
            .label("Updated")
            .build();
        categoryService.updateCategory(user, inCategory.getCode(), requestCategory);
        var updatedCategory = categoryRepo.findByUserAndCode(user, inCategory.getCode());
        assertTrue(updatedCategory.isEmpty());
        updatedCategory = categoryRepo.findByUserAndCode(user, requestCategory.getCode());
        assertTrue(updatedCategory.isPresent());
        assertEquals(requestCategory.getCode(), updatedCategory.get().getCode());
        assertEquals(requestCategory.getLabel(), updatedCategory.get().getLabel());

        var categories = categoryRepo.findByUser(user);
        assertFalse(categories.isEmpty());
        assertEquals(1, categories.size());
        assertEquals(requestCategory.getCode(), categories.getFirst().getCode());
        assertEquals(requestCategory.getLabel(), categories.getFirst().getLabel());
    }

    private JpaUser createUser() {
        var user = JpaUser.builder()
            .name("Test")
            .codeType(UserCodeType.EMAIL)
            .code("test@mail.com")
            .password("test")
            .build();
        return userRepo.save(user);
    }
}
