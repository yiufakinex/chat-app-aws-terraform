package com.franklin.backend.form;

import com.franklin.backend.entity.GroupChat;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter
@Setter
public class RenameGroupChatForm {

    @Size(min = 1, max = 40, message = GroupChat.INVALID_NAME)
    @NotBlank(message = GroupChat.INVALID_NAME)
    private String name;
}