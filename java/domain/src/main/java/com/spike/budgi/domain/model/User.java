package com.spike.budgi.domain.model;

public interface User extends Base {
    String getName();

    UserCodeType getCodeType();

    String getPassword();
}
