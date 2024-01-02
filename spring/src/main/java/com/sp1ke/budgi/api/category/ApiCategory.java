package com.sp1ke.budgi.api.category;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Builder
@Getter
@Setter
public class ApiCategory {
    private String code;

    private String name;
}
