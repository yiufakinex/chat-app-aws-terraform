package com.franklin.backend.controller;

import java.util.HashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.franklin.backend.annotation.GetUser;
import com.franklin.backend.entity.User;
import com.franklin.backend.service.UserService;
import com.franklin.backend.util.Response;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping(path = "/search", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<HashMap<String, Object>> search(@GetUser User user,
            @RequestParam("username") String username) {
        return new ResponseEntity<>(Response.createBody("user", userService.findByUsername(username)), HttpStatus.OK);
    }

    @RequestMapping(path = "/update/display_name", method = { RequestMethod.POST,
            RequestMethod.PATCH }, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<HashMap<String, Object>> updateDisplayName(@GetUser User user,
            @RequestParam("displayName") String displayName) {
        return new ResponseEntity<>(Response.createBody("user", userService.updateDisplayName(user, displayName)),
                HttpStatus.OK);
    }
}