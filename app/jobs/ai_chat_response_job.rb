class AIChatResponseJob < ApplicationJob
  def perform(ai_chat_id, content)
    ai_chat = AI::Chat.find(ai_chat_id)

    ai_chat.ask(content) do |chunk|
      if chunk.content && !chunk.content.empty?
        ai_message = ai_chat.ai_messages.last
        ai_message.broadcast_append_chunk(chunk.content)
      end
    end
  end
end
