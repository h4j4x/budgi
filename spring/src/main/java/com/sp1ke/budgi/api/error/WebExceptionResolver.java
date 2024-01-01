package com.sp1ke.budgi.api.error;

import com.sp1ke.budgi.api.model.ApiMessage;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@ControllerAdvice
public class WebExceptionResolver extends ResponseEntityExceptionHandler {
    @ExceptionHandler(BadRequestException.class)
    protected ResponseEntity<ApiMessage> handleBadRequestException(BadRequestException ex) {
        var apiMessage = ApiMessage.builder()
            .message(ex.getMessage())
            .build();
        return ResponseEntity.badRequest().body(apiMessage);
    }
}
