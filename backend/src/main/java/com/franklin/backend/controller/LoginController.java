package com.franklin.backend.controller;

import java.net.URI;
import java.util.HashMap;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.franklin.backend.annotation.GetUser;
import com.franklin.backend.entity.User;
import com.franklin.backend.entity.User.Role;
import com.franklin.backend.service.UserService;
import com.franklin.backend.util.Response;

@RestController
@RequestMapping("/api/login")
public class LoginController {

    @Autowired
    private UserService userService;

    @GetMapping(path = "/principal", produces = MediaType.APPLICATION_JSON_VALUE)
    public OAuth2User principal(@AuthenticationPrincipal OAuth2User user) {
        return user;
    }

    @GetMapping(path = "/user", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<HashMap<String, Object>> user(@GetUser User user) {
        String[] keys = { "user", "loggedIn", "newUser" };

        Optional<User> optionalUser = Optional.ofNullable(user);
        boolean loggedIn = optionalUser.isPresent();
        boolean newUser = optionalUser
                .map(u -> u.getRole().equals(Role.NEW_USER))
                .orElse(false);

        Object[] vals = { optionalUser.orElse(null), loggedIn, newUser };
        return new ResponseEntity<>(Response.createBody(keys, vals), HttpStatus.OK);
    }

    @GetMapping("/new_user")
    public ResponseEntity<Void> newUserPage() {
        return ResponseEntity.status(HttpStatus.FOUND)
                .location(URI.create("/register"))
                .build();
    }

    @PostMapping(path = "/new_user", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
    public ResponseEntity<HashMap<String, Object>> newUser(
            @GetUser User user,
            @RequestParam("username") String username,
            @AuthenticationPrincipal OAuth2User oAuth2User) {
        userService.newUser(user, username, oAuth2User);
        return new ResponseEntity<>(Response.createBody("message", "User created successfully"), HttpStatus.OK);
    }
}
