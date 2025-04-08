package com.franklin.backend.advice;

import java.util.HashMap;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import com.franklin.backend.exception.InvalidUserException;
import com.franklin.backend.util.Response;

@ControllerAdvice
public class InvalidUserExceptionHandler {

    @ExceptionHandler(InvalidUserException.class)
    public ResponseEntity<HashMap<String, Object>> handleInvalidUserException(InvalidUserException e) {
        return Response.unauthorized();
    }
}