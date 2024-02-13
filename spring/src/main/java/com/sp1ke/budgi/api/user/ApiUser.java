package com.sp1ke.budgi.api.user;

import com.sp1ke.budgi.api.common.PeriodType;
import lombok.Builder;
import lombok.Getter;

@Builder
@Getter
public class ApiUser {
    private String name;

    private String email;

    private String password;

    private PeriodType periodType;
}
