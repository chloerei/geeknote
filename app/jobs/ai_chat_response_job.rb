class AIChatResponseJob < ApplicationJob
  def perform(ai_chat)
    ai_chat_agent = WritingAgent.new(chat: ai_chat, persist_instructions: false)
    ai_chat_agent.complete do |chunk|
      if chunk.content && !chunk.content.empty?
        ai_message = ai_chat_agent.chat.ai_messages.last
        ai_message.broadcast_append_chunk(chunk.content)
      end
    end
  end
end
