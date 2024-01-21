package com.sp1ke.budgi.api.common;

import lombok.Getter;
import lombok.extern.jackson.Jacksonized;

@Jacksonized
@Getter
public class ApiFilter<T> {
    private String search;
}
