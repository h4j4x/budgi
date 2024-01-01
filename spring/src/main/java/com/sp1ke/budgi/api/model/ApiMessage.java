package com.sp1ke.budgi.api.model;

import lombok.Builder;
import lombok.Getter;
import lombok.extern.jackson.Jacksonized;

@Builder
@Jacksonized
@Getter
public class ApiMessage {
    private final String message;
}
