package com.spike.budgi.domain;

import java.time.OffsetDateTime;

public interface Base {
    String getCode();

    OffsetDateTime getCreatedAt();

    OffsetDateTime getUpdatedAt();

    boolean isEnabled();
}
