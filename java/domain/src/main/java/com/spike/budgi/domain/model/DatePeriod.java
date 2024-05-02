package com.spike.budgi.domain.model;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

public record DatePeriod(@NotNull LocalDate from, @NotNull LocalDate to) {
}
