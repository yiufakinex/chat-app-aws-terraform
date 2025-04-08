package com.franklin.backend.form;

import lombok.*;

@Getter
@Setter
public class WebSocketMessageForm {
    private Long chatId;
    private String content;
}