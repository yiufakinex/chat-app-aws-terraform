package com.franklin.backend.service;

import java.util.Optional;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import com.franklin.backend.entity.GroupChat;
import com.franklin.backend.entity.Message;
import com.franklin.backend.entity.User;
import com.franklin.backend.entity.Message.MessageType;
import com.franklin.backend.exception.InvalidGroupChatException;
import com.franklin.backend.exception.InvalidInputException;
import com.franklin.backend.exception.InvalidUserException;
import com.franklin.backend.form.AddGroupChatUserForm;
import com.franklin.backend.form.ChatNotification;
import com.franklin.backend.form.NewGroupChatForm;
import com.franklin.backend.form.RenameGroupChatForm;
import com.franklin.backend.repository.GroupChatRepository;
import com.franklin.backend.repository.MessageRepository;
import com.franklin.backend.util.CustomValidator;
import com.franklin.backend.util.DateFormat;

@Service
public class GroupChatService {
    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private UserService userService;

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private GroupChatRepository groupChatRepository;

    private final CustomValidator<GroupChat> validator = new CustomValidator<>();

    private final CustomValidator<AddGroupChatUserForm> addGroupChatUserFormValidator = new CustomValidator<>();

    private final CustomValidator<RenameGroupChatForm> renameGroupChatFormValidator = new CustomValidator<>();

    public GroupChat newGroupChat(User user, NewGroupChatForm newGroupChatForm) {
        if (newGroupChatForm == null || newGroupChatForm.getUsernames() == null
                || newGroupChatForm.getUsernames().size() > 100) {
            throw new InvalidInputException("Invalid input");
        }
        GroupChat groupChat = GroupChat.builder()
                .name(newGroupChatForm.getName())
                .lastMessageAt(DateFormat.getUnixTime())
                .build();
        validator.validate(groupChat);
        groupChatRepository.save(groupChat);

        if (!newGroupChatForm.getUsernames().contains(user.getUsername())) {
            newGroupChatForm.getUsernames().add(user.getUsername());
        }

        for (String username : newGroupChatForm.getUsernames()) {
            User member = userService.findUserJoinedWithGroupChat(username);
            groupChat.addToGroupChat(member);
        }

        GroupChat savedGroupChat = groupChatRepository.save(groupChat);

        for (User member : savedGroupChat.getUsers()) {
            messagingTemplate.convertAndSend(
                    "/topic/user." + member.getId() + ".chats",
                    new ChatNotification("System", savedGroupChat.getId(),
                            "You were added to " + savedGroupChat.getName()));
        }

        return savedGroupChat;
    }

    public Set<GroupChat> getGroupChats(User user) {
        return userService.findUserJoinedWithGroupChat(user.getUsername()).getGroupChats();
    }

    public Optional<GroupChat> findById(Long id) {
        return groupChatRepository.findById(id);
    }

    public GroupChat validateUserInGroupChat(User user, Long groupChatId) {
        Optional<GroupChat> optional = groupChatRepository.findById(groupChatId);
        if (!optional.isPresent()) {
            throw new InvalidGroupChatException();
        }
        GroupChat groupChat = optional.get();
        if (!groupChat.getUsers().contains(user)) {
            throw new InvalidUserException();
        }
        return groupChat;
    }

    public Message addUser(User user, AddGroupChatUserForm form, Long groupChatId) {
        GroupChat groupChat = validateUserInGroupChat(user, groupChatId);
        addGroupChatUserFormValidator.validate(form);
        User newUser = userService.findUserJoinedWithGroupChat(form.getUsername());
        if (groupChat.getUsers().contains(newUser)) {
            return null;
        }
        groupChat.addToGroupChat(newUser);
        Message message = Message.builder()
                .content(String.format("'@%s' was added to the chat by '@%s'.", newUser.getUsername(),
                        user.getUsername()))
                .createdAt(DateFormat.getUnixTime())
                .modifiedAt(DateFormat.getUnixTime())
                .messageType(MessageType.USER_JOIN)
                .sender(user)
                .groupChat(groupChat)
                .build();
        groupChat.setLastMessageAt(DateFormat.getUnixTime());
        groupChatRepository.save(groupChat);

        messagingTemplate.convertAndSend(
                "/topic/user." + newUser.getId() + ".chats",
                new ChatNotification("System", groupChat.getId(), "You were added to " + groupChat.getName()));

        return messageRepository.save(message);
    }

    public Message removeUser(User user, Long groupChatId) {
        GroupChat groupChat = validateUserInGroupChat(user, groupChatId);
        user = userService.findUserJoinedWithGroupChat(user.getUsername());
        Message message = Message.builder()
                .content(String.format("'@%s' left the chat.", user.getUsername()))
                .createdAt(DateFormat.getUnixTime())
                .modifiedAt(DateFormat.getUnixTime())
                .messageType(MessageType.USER_LEAVE)
                .sender(user)
                .groupChat(groupChat)
                .build();
        groupChat.removeFromGroupChat(user);
        groupChat.setLastMessageAt(DateFormat.getUnixTime());
        groupChatRepository.save(groupChat);
        return messageRepository.save(message);
    }

    public Message renameGroupChat(User user, RenameGroupChatForm form, Long groupChatId) {
        GroupChat groupChat = validateUserInGroupChat(user, groupChatId);
        renameGroupChatFormValidator.validate(form);
        if (groupChat.getName().equals(form.getName())) {
            return null;
        }
        Message message = Message.builder()
                .content(String.format("'@%s' renamed the chat to '%s'", user.getUsername(), form.getName()))
                .createdAt(DateFormat.getUnixTime())
                .modifiedAt(DateFormat.getUnixTime())
                .messageType(MessageType.USER_RENAME)
                .sender(user)
                .groupChat(groupChat)
                .build();
        groupChat.setLastMessageAt(DateFormat.getUnixTime());
        groupChat.setName(form.getName());
        groupChatRepository.save(groupChat);

        for (User member : groupChat.getUsers()) {
            if (!member.getId().equals(user.getId())) {
                messagingTemplate.convertAndSend(
                        "/topic/user." + member.getId() + ".chats",
                        new ChatNotification("System", groupChat.getId(),
                                String.format("'@%s' renamed the chat to '%s'", user.getUsername(), form.getName())));
            }
        }

        return messageRepository.save(message);
    }
}
