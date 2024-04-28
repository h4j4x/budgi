package com.spike.budgi.domain.model;

public interface User extends Base, Validatable {
    String getName();

    UserCodeType getCodeType();

    String getPassword();
}
