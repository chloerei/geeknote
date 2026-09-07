class AIChatResponseJob < ApplicationJob
  queue_as :llm

  # Rate limit broadcasts: hold incoming chunks and send them together in one
  # broadcast every 100ms, so we push fewer Turbo Stream messages.
  BROADCAST_INTERVAL_SECONDS = 0.1

  def perform(ai_chat)
    @ai_chat_agent = WritingAgent.new(chat: ai_chat, persist_instructions: false)
    @pending_content = +""
    @pending_thinking = +""
    @thinking_text = +""
    @last_broadcast_at = Time.now
    @broadcast_message_id = nil

    begin
      @ai_chat_agent.complete do |chunk|
        collect(chunk)
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

  # Each chunk carries either a reasoning delta (thinking) or answer text, and
  # reasoning always precedes the answer, so the two buffers never interleave
  # within one generation.
  def collect(chunk)
    thinking = chunk.thinking&.text
    @pending_thinking << thinking if thinking.present?
    @pending_content << chunk.content if chunk.content.present?
  end

  def flush_broadcast
    flushed = flush_thinking
    flushed = flush_content || flushed
    @last_broadcast_at = Time.now if flushed
  end

  # Each generation turn streams into a fresh assistant shell row, so the
  # thinking/content progress below is scoped to the message being streamed.
  def current_message
    message = @ai_chat_agent.chat.ai_messages.last
    unless message.id == @broadcast_message_id
      @broadcast_message_id = message.id
      @thinking_streamed = false
      @content_started = false
      @thinking_text = +""
    end
    message
  end

  def flush_thinking
    return false if @pending_thinking.empty?

    message = current_message
    @thinking_text << @pending_thinking
    message.broadcast_append_thinking_chunk(@pending_thinking)
    @pending_thinking = +""
    @thinking_streamed = true
    true
  end

  def flush_content
    return false if @pending_content.empty?

    message = current_message
    first_content = !@content_started
    @content_started = true

    message.broadcast_append_chunk(@pending_content)
    @pending_content = +""

    if first_content
      if @thinking_streamed
        # Reasoning is over and the answer is starting: persist the reasoning
        # text that has streamed into the live card, then replace the whole
        # thinking card (spinner, open) with its completed rendering (icon,
        # collapsed) — AI::Message#broadcast_thinking_finished.
        message.update_column(:thinking_text, @thinking_text)
        message.broadcast_thinking_finished
      else
        # The answer is starting without any reasoning: the thinking card the
        # streaming shell rendered would stay empty forever, so remove it.
        message.broadcast_remove_empty_thinking_card
      end
    end
    true
  end
end
