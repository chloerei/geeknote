class AIChatResponseJob < ApplicationJob
  def perform(ai_chat)
    ai_chat.complete do |chunk|
      if chunk.content && !chunk.content.empty?
        ai_message = ai_chat.ai_messages.last
        ai_message.broadcast_append_chunk(chunk.content)
      end
    end
  end
end
