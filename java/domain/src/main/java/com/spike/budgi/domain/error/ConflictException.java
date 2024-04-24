package com.spike.budgi.domain.error;

public class ConflictException extends Exception {
    public ConflictException(String message) {
        super(message);
    }
}
