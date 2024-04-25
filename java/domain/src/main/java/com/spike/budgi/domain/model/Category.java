package com.spike.budgi.domain.model;

public interface Category extends Base {
    User getUser();

    String getLabel();

    String getDescription();
}
