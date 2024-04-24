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
    void testSaveNewValidUser() throws ConflictException {
        var inUser = JpaUser.builder()
            .name("Test")
            .codeType(UserCodeType.EMAIL)
            .code("test@mail.com")
            .password("test")
            .build();
        var savedUser = userService.saveUser(inUser, true);
        assertEquals(inUser.getCode(), savedUser.getCode());
        assertEquals(inUser.getName(), savedUser.getName());

        var repoUser = userRepo.findByCode(inUser.getCode()).orElseThrow();
        assertEquals(inUser.getCode(), repoUser.getCode());
        assertEquals(inUser.getName(), repoUser.getName());
    }

    @Test
    public void testSaveInvalidEmailThrowsValidation() {
        var inUser = JpaUser.builder()
            .codeType(UserCodeType.EMAIL)
            .code("test")
            .build();
        var validationException = assertThrows(ValidationException.class,
            () -> userService.saveUser(inUser, true));
        assertEquals("User email must be valid.", validationException.getMessage());

        inUser.setCode("test@mail.com");
        validationException = assertThrows(ValidationException.class,
            () -> userService.saveUser(inUser, true));
        assertEquals("User name is required.", validationException.getMessage());
    }
}
