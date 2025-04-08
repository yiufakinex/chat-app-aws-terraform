package com.franklin.backend.form;

import java.util.Set;

import lombok.*;

@Getter
@Setter
public class NewGroupChatForm {

    private String name;

    private Set<String> usernames;

}