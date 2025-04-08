package com.franklin.backend.exception;

import lombok.Getter;

@Getter
public class InvalidUsernameException extends InvalidInputException {

    private String username;

    public InvalidUsernameException(String msg, String username) {
        super(msg);
        this.username = username;
    }
}
