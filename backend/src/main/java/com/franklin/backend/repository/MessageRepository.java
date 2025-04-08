package com.franklin.backend.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.franklin.backend.entity.Message;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {

    @Query(value = """
            SELECT m FROM Message m
            LEFT JOIN FETCH m.sender s
            LEFT JOIN FETCH m.groupChat gc
            WHERE m.groupChat.id = :groupId
            AND m.createdAt < :before
            ORDER BY m.createdAt DESC
            """, countQuery = """
            SELECT COUNT(m) FROM Message m
            WHERE m.groupChat.id = :groupId
            AND m.createdAt < :before
            """)
    Page<Message> findAllInGroupChatWithPagination(
            Pageable pageable,
            @Param("groupId") Long groupId,
            @Param("before") Long before);

    @Query("""
            SELECT COUNT(m) > 0 FROM Message m
            WHERE m.groupChat.id = :groupId
            AND m.createdAt > :timestamp
            """)
    boolean hasNewMessages(
            @Param("groupId") Long groupId,
            @Param("timestamp") Long timestamp);
}
