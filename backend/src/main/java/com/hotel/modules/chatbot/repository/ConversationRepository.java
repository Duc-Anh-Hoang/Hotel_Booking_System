package com.hotel.modules.chatbot.repository;

import com.hotel.modules.chatbot.entity.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ConversationRepository extends JpaRepository<Conversation,Long> {
}
