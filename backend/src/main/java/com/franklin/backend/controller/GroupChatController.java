package com.franklin.backend.controller;

import java.util.HashMap;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import com.franklin.backend.form.AddGroupChatUserForm;
import com.franklin.backend.form.NewGroupChatForm;
import com.franklin.backend.form.RenameGroupChatForm;
import com.franklin.backend.entity.Message;
import com.franklin.backend.entity.User;
import com.franklin.backend.annotation.GetUser;
import com.franklin.backend.util.Response;
import com.franklin.backend.service.GroupChatService;
import com.franklin.backend.service.UserService;

@RestController
@RequestMapping("/api/groupchat")
public class GroupChatController {
    private final GroupChatService groupChatService;

    public GroupChatController(GroupChatService groupChatService, UserService userService) {
        this.groupChatService = groupChatService;

    }

    @PostMapping(path = "/new", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<HashMap<String, Object>> newGroupChat(@GetUser User user,
            @RequestBody NewGroupChatForm newGroupChatForm) {
        return new ResponseEntity<>(
                Response.createBody("groupChat", groupChatService.newGroupChat(user, newGroupChatForm)), HttpStatus.OK);
    }

    @GetMapping(path = "/get", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<HashMap<String, Object>> getGroupChats(@GetUser User user) {
        return new ResponseEntity<>(Response.createBody("groupChats", groupChatService.getGroupChats(user)),
                HttpStatus.OK);
    }

    @PostMapping(path = "/{id}/users/add", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<HashMap<String, Object>> addUserRest(
            @GetUser User user,
            @PathVariable("id") Long id,
            @RequestBody AddGroupChatUserForm form) {
        Message message = groupChatService.addUser(user, form, id);
        return new ResponseEntity<>(Response.createBody("message", message), HttpStatus.OK);
    }

    @PostMapping(path = "/{id}/users/remove", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<HashMap<String, Object>> removeUserRest(
            @GetUser User user,
            @PathVariable("id") Long id) {
        Message message = groupChatService.removeUser(user, id);
        return new ResponseEntity<>(Response.createBody("message", message), HttpStatus.OK);
    }

    @PatchMapping(path = "/{id}/rename", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<HashMap<String, Object>> renameGroupChatRest(
            @GetUser User user,
            @PathVariable("id") Long id,
            @RequestBody RenameGroupChatForm form) {
        Message message = groupChatService.renameGroupChat(user, form, id);
        return new ResponseEntity<>(Response.createBody("message", message), HttpStatus.OK);
    }
}