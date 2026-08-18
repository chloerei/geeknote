class AI::Chat < ApplicationRecord
  acts_as_chat messages: :ai_messages, message_class: "AI::Message", messages_foreign_key: :ai_chat_id

  belongs_to :post
  belongs_to :user

  # 历史列表上显示的标题：取第一条用户消息作为摘要
  def title
    ai_messages.find { |message| message.role == "user" }&.content.presence
  end
end
