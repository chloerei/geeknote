class AI::Message < ApplicationRecord
  acts_as_message chat: :ai_chat, chat_class: 'AI::Chat'
  has_many_attached :attachments

  broadcasts_to ->(ai_message) { ai_message.ai_chat }, inserts_by: :append

  def broadcast_append_chunk(content)
    broadcast_append_to ai_chat,
      target: "ai_message_#{id}_content",
      content: ERB::Util.html_escape(content.to_s)
  end
end
