package com.sp1ke.budgi.api.category;

import java.io.Serializable;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Builder
@Getter
@Setter
public class ApiCategory implements Serializable {
    private String code;

    private String name;
}
