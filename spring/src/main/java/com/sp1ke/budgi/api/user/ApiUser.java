package com.sp1ke.budgi.api.user;

import lombok.Builder;
import lombok.Getter;

@Builder
@Getter
public class ApiUser {
    private String name;

    private String email;

    private String password;
}
