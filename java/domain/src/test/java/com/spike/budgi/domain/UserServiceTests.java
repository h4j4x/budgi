package com.spike.budgi.domain;

import com.spike.budgi.domain.error.ConflictException;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.UserCodeType;
import com.spike.budgi.domain.repo.UserRepo;
import jakarta.validation.ValidationException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class UserServiceTests {
    final UserRepo userRepo;

    final UserService userService;

    @Autowired
    public UserServiceTests(UserRepo userRepo, UserService userService) {
        this.userRepo = userRepo;
        this.userService = userService;
    }

    @BeforeEach
    void beforeEach() {
        userRepo.deleteAll();
    }

    @Test
    void contextLoad() {
        assertNotNull(userRepo);
        assertNotNull(userService);
    }

    @Test
    void testCreateValidUser() throws ConflictException {
        var inUser = JpaUser.builder()
            .name("Test")
            .codeType(UserCodeType.EMAIL)
            .code("test@mail.com")
            .password("test")
            .build();
        var savedUser = userService.createUser(inUser);
        assertEquals(inUser.getCode(), savedUser.getCode());
        assertEquals(inUser.getName(), savedUser.getName());

        var repoUser = userRepo.findByCode(inUser.getCode()).orElseThrow();
        assertEquals(inUser.getCode(), repoUser.getCode());
        assertEquals(inUser.getName(), repoUser.getName());
    }

    @Test
    public void testCreateInvalidEmailThrowsValidation() {
        var inUser = JpaUser.builder()
            .codeType(UserCodeType.EMAIL)
            .code("test")
            .build();
        var validationException = assertThrows(ValidationException.class,
            () -> userService.createUser(inUser));
        assertEquals("User email must be valid.", validationException.getMessage());

        inUser.setCode("test@mail.com");
        validationException = assertThrows(ValidationException.class,
            () -> userService.createUser(inUser));
        assertEquals("User name is required.", validationException.getMessage());
    }

    @Test
    void testCreateExistentUserCode() {
        var inUser = JpaUser.builder()
            .name("Test")
            .codeType(UserCodeType.EMAIL)
            .code("test@mail.com")
            .password("test")
            .build();
        userRepo.save(inUser);
        var conflictException = assertThrows(ConflictException.class,
            () -> userService.createUser(inUser));
        assertEquals("User code already registered.", conflictException.getMessage());
    }

    @Test
    void testUpdateUser() throws ConflictException {
        var inUser = JpaUser.builder()
            .name("Test")
            .codeType(UserCodeType.EMAIL)
            .code("test@mail.com")
            .password("test")
            .build();
        userService.createUser(inUser);

        var requestUser = inUser.toBuilder()
            .name("Updated")
            .code("updated@mail.com")
            .password("updated")
            .build();
        userService.updateUser(inUser.getCode(), requestUser);
        var updatedUser = userService.findUser(inUser.getCode());
        assertTrue(updatedUser.isEmpty());
        updatedUser = userService.findUser(requestUser.getCode());
        assertTrue(updatedUser.isPresent());
        assertEquals(requestUser.getCode(), updatedUser.get().getCode());
        assertEquals(requestUser.getName(), updatedUser.get().getName());
        assertEquals(requestUser.getPassword(), updatedUser.get().getPassword());
    }
}
