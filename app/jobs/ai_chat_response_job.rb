class AIChatResponseJob < ApplicationJob
  queue_as :llm

  # Rate limit broadcasts: hold incoming chunks and send them together in one
  # broadcast every 100ms, so we push fewer Turbo Stream messages.
  BROADCAST_INTERVAL_SECONDS = 0.1

  def perform(ai_chat)
    @ai_chat_agent = WritingAgent.new(chat: ai_chat, persist_instructions: false)
    @pending_content = +""
    @last_broadcast_at = Time.now

    begin
      @ai_chat_agent.complete do |chunk|
        next if chunk.content.blank?

        @pending_content << chunk.content
        flush_broadcast if broadcast_due?
      end
    ensure
      # Send any remaining buffered content when the stream ends (even on errors).
      flush_broadcast
    end
  end

  private

  def broadcast_due?
    Time.now - @last_broadcast_at >= BROADCAST_INTERVAL_SECONDS
  end

  def flush_broadcast
    return if @pending_content.empty?

    ai_message = @ai_chat_agent.chat.ai_messages.last
    ai_message.broadcast_append_chunk(@pending_content)
    @pending_content = +""
    @last_broadcast_at = Time.now
  end
end
