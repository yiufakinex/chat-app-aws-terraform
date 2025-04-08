package com.franklin.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.franklin.backend.entity.GroupChat;
import com.franklin.backend.entity.Message;
import com.franklin.backend.entity.User;
import com.franklin.backend.entity.Message.MessageType;
import com.franklin.backend.form.PaginationForm;
import com.franklin.backend.repository.GroupChatRepository;
import com.franklin.backend.repository.MessageRepository;
import com.franklin.backend.util.CustomValidator;
import com.franklin.backend.util.DateFormat;

@Service
public class MessageService {

    @Autowired
    private GroupChatRepository groupChatRepository;

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private GroupChatService groupChatService;

    private final CustomValidator<Message> validator = new CustomValidator<>();

    private final CustomValidator<PaginationForm> paginationFormValidator = new CustomValidator<>();

    @Transactional(readOnly = true)
    public Page<Message> getMessages(User user, Long groupId, PaginationForm paginationForm, Long before) {
        paginationFormValidator.validate(paginationForm);
        groupChatService.validateUserInGroupChat(user, groupId);

        Pageable pageable = PageRequest.of(
                paginationForm.getPageNum(),
                paginationForm.getPageSize());

        return messageRepository.findAllInGroupChatWithPagination(
                pageable,
                groupId,
                before);
    }

    @Transactional
    public Message sendMessage(Long groupChatId, String messageContent, User user) {
        GroupChat groupChat = groupChatService.validateUserInGroupChat(user, groupChatId);

        Message message = Message.builder()
                .content(messageContent)
                .createdAt(DateFormat.getUnixTime())
                .modifiedAt(DateFormat.getUnixTime())
                .messageType(MessageType.USER_CHAT)
                .sender(user)
                .groupChat(groupChat)
                .build();

        validator.validate(message);

        groupChat.setLastMessageAt(message.getCreatedAt());
        groupChatRepository.save(groupChat);
        return messageRepository.save(message);
    }
}
