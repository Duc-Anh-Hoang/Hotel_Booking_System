package com.hotel.modules.chatbot.repository;

import com.hotel.modules.chatbot.entity.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChatMessageRepository extends JpaRepository<ChatMessage,Long> {
}
