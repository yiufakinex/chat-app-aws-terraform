package com.franklin.backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.security.core.Authentication;

import com.franklin.backend.entity.GroupChat;
import com.franklin.backend.entity.Message;
import com.franklin.backend.entity.User;
import com.franklin.backend.security.CustomOAuth2User;
import com.franklin.backend.service.MessageService;
import com.franklin.backend.form.ChatNotification;
import com.franklin.backend.form.WebSocketMessageForm;

@Controller
public class WebSocketMessageController {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private MessageService messageService;

    @MessageMapping("/chat.send")
    public void sendMessage(@Payload WebSocketMessageForm messageForm, Authentication authentication) {
        CustomOAuth2User oauth2User = (CustomOAuth2User) authentication.getPrincipal();
        User user = oauth2User.getUser();
        Message message = messageService.sendMessage(messageForm.getChatId(), messageForm.getContent(), user);

        messagingTemplate.convertAndSend("/topic/chat." + messageForm.getChatId(), message);
        messagingTemplate.convertAndSend(
                "/topic/notifications." + messageForm.getChatId(),
                new ChatNotification(user.getUsername(), messageForm.getChatId(), message.getContent()));
    }

    @MessageMapping("/chat.typing")
    public void typingNotification(@Payload TypingNotification notification, Authentication authentication) {
        CustomOAuth2User oauth2User = (CustomOAuth2User) authentication.getPrincipal();
        User user = oauth2User.getUser();

        notification.setUsername(user.getUsername());

        messagingTemplate.convertAndSend(
                "/topic/chat." + notification.getChatId() + ".typing",
                notification);
    }

    @MessageMapping("/chat.create")
    public void notifyNewChat(@Payload GroupChat groupChat) {
        for (User user : groupChat.getUsers()) {
            messagingTemplate.convertAndSend(
                    "/topic/user." + user.getId() + ".chats",
                    new ChatNotification("System", groupChat.getId(), "You were added to " + groupChat.getName()));
        }
    }
}

class TypingNotification {
    private Long chatId;
    private String username;
    private boolean typing;

    public Long getChatId() {
        return chatId;
    }

    public void setChatId(Long chatId) {
        this.chatId = chatId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public boolean isTyping() {
        return typing;
    }

    public void setTyping(boolean typing) {
        this.typing = typing;
    }
}