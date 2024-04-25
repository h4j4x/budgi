package com.spike.budgi.domain.error;

public class NotFoundException extends Exception {
    public NotFoundException(String message) {
        super(message);
    }
}
