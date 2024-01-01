package com.sp1ke.budgi.api.error;

import lombok.Builder;
import lombok.Getter;
import lombok.extern.jackson.Jacksonized;

@Builder
@Jacksonized
@Getter
public class ApiMessage {
    private final String message;
}
