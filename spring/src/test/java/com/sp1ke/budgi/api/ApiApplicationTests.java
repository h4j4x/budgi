package com.sp1ke.budgi.api;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.modulith.core.ApplicationModules;

@SpringBootTest
class ApiApplicationTests {
    final ApplicationModules modules = ApplicationModules.of(ApiApplication.class);

    @Test
    void contextLoads() {
    }

    @Test
    void shouldBeCompliant() {
        modules.verify();
    }
}
