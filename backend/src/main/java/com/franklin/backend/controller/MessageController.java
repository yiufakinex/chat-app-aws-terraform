package com.franklin.backend.controller;

import java.util.HashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;

import com.franklin.backend.annotation.GetUser;
import com.franklin.backend.entity.Message;
import com.franklin.backend.entity.User;
import com.franklin.backend.form.NewMessageForm;
import com.franklin.backend.form.PaginationForm;
import com.franklin.backend.service.MessageService;
import com.franklin.backend.util.Response;

@RestController
@RequestMapping("/api/message")
public class MessageController {
    @Autowired
    private MessageService messageService;

    @PostMapping(path = "/send/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Message> sendMessage(@GetUser User user,
            @PathVariable("id") Long id,
            @RequestBody NewMessageForm newMessageForm) {
        Message message = messageService.sendMessage(id, newMessageForm.getContent(), user);
        return ResponseEntity.ok(message);
    }

    @GetMapping(path = "/{id}/get", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<HashMap<String, Object>> getMessages(@GetUser User user,
            @PathVariable("id") Long id,
            PaginationForm paginationForm,
            @RequestParam("before") Long before) {
        return Response.page(messageService.getMessages(user, id, paginationForm, before));
    }
}