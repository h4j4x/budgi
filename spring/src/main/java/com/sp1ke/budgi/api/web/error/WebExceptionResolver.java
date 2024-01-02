package com.sp1ke.budgi.api.web.error;

import com.sp1ke.budgi.api.common.ApiMessage;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@ControllerAdvice
public class WebExceptionResolver extends ResponseEntityExceptionHandler {
    @ExceptionHandler(HttpClientErrorException.class)
    protected ResponseEntity<ApiMessage> handleHttpClientErrorException(HttpClientErrorException e) {
        return handle(e.getStatusCode().value(), e.getMessage());
    }

    private ResponseEntity<ApiMessage> handle(int status, String message) {
        var apiMessage = ApiMessage.builder()
            .message(message)
            .build();
        return ResponseEntity.status(status).body(apiMessage);
    }
}
