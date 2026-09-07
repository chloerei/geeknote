class AI::Chat < ApplicationRecord
  acts_as_chat messages: :ai_messages, message_class: "AI::Message", messages_foreign_key: :ai_chat_id

  belongs_to :post
  belongs_to :user

  # Title shown in the chat history list: the first user message, used as a summary.
  def title
    ai_messages.find { |message| message.role == "user" }&.content.presence
  end

  # Identifier of the current conversation round: the user message that started
  # it. AI suggestion broadcasts carry it so the editor can discard suggestions
  # from late or stale rounds.
  def round_id
    ai_messages.where(role: "user").order(id: :desc).pick(:id)
  end
end
