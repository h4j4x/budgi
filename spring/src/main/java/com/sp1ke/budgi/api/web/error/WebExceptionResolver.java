package com.sp1ke.budgi.api.web.error;

import com.sp1ke.budgi.api.error.ApiMessage;
import com.sp1ke.budgi.api.error.BadRequestException;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@ControllerAdvice
public class WebExceptionResolver extends ResponseEntityExceptionHandler {
    @ExceptionHandler(BadRequestException.class)
    protected ResponseEntity<ApiMessage> handleBadRequestException(BadRequestException ex) {
        return handle(400, ex.getMessage());
    }

    @ExceptionHandler(BadCredentialsException.class)
    protected ResponseEntity<ApiMessage> handleBadCredentialsException(BadCredentialsException ex) {
        return handle(401, ex.getMessage());
    }

    @ExceptionHandler({UsernameNotFoundException.class, EntityNotFoundException.class})
    protected ResponseEntity<ApiMessage> handleNotFoundException(Exception ex) {
        return handle(404, ex.getMessage());
    }

    @ExceptionHandler(LockedException.class)
    protected ResponseEntity<ApiMessage> handleLockedException(LockedException ex) {
        return handle(409, ex.getMessage());
    }

    private ResponseEntity<ApiMessage> handle(int status, String message) {
        var apiMessage = ApiMessage.builder()
            .message(message)
            .build();
        return ResponseEntity.status(status).body(apiMessage);
    }
}
