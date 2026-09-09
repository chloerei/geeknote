class AIChatTitleJob < ApplicationJob
  queue_as :llm

  # Titles a chat from its first user message. Runs once when a chat is
  # created; later messages never retitle the conversation.
  SYSTEM_PROMPT = <<~PROMPT
    You write short titles for an AI writing-assistant chat log.
    Summarize what the user's message asks for in a title written in the same
    language as the message.
    Reply with only the title itself: no quotes, no prefixes such as "Title:",
    no trailing punctuation, at most 30 characters.
  PROMPT

  TITLE_LENGTH_LIMIT = 60

  def perform(ai_chat)
    return if ai_chat.title.present?

    first_user_message = ai_chat.ai_messages.where(role: "user").order(:id).first
    return if first_user_message.nil? || first_user_message.content.blank?

    title = RubyLLM.chat
      .with_instructions(SYSTEM_PROMPT)
      .ask(first_user_message.content)
      .content
      .to_s
    title = sanitize_title(title)
    ai_chat.update_columns(title: title) if title.present?
  end

  private

  # The prompt already constrains the output to a bare short title, so no
  # content rewriting here: only trim whitespace and cap the length, keeping
  # the stored value tidy for the history list.
  def sanitize_title(title)
    title = title.strip.gsub(/\s+/, " ")
    title[0, TITLE_LENGTH_LIMIT].to_s.strip
  end
end
