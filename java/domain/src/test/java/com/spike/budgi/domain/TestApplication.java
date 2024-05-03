package com.spike.budgi.domain;

import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.UserCodeType;
import com.spike.budgi.domain.repo.UserRepo;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootApplication
public class TestApplication {
    @NotNull
    public static JpaUser createUser(@NotNull UserRepo userRepo) {
        var user = JpaUser.builder()
            .name("Test " + System.currentTimeMillis())
            .codeType(UserCodeType.EMAIL)
            .code(System.currentTimeMillis() + "@mail.com")
            .password("test")
            .build();
        return userRepo.save(user);
    }

    public static void assertBigDecimalEquals(BigDecimal expected, BigDecimal actual) {
        assertEquals(expected.stripTrailingZeros(), actual.stripTrailingZeros());
    }
}
