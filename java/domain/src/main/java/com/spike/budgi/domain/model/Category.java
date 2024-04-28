package com.spike.budgi.domain.model;

public interface Category extends Base, Validatable {
    User getUser();

    String getLabel();

    String getDescription();
}
