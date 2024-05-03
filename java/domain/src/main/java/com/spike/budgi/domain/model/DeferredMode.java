package com.spike.budgi.domain.model;

import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;

public record DeferredMode(int months, int delayMonths) {
    @NotNull
    public OffsetDateTime startDateTime() {
        return OffsetDateTime.now().plusMonths(delayMonths);
    }
}
