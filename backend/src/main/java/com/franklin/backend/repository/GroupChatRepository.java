package com.franklin.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.franklin.backend.entity.GroupChat;

@Repository
public interface GroupChatRepository extends JpaRepository<GroupChat, Long> {

}
