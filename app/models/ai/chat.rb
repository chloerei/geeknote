class AI::Chat < ApplicationRecord
  acts_as_chat messages: :ai_messages, message_class: "AI::Message", messages_foreign_key: :ai_chat_id

  belongs_to :post
  belongs_to :user

  # 历史列表上显示的标题：取第一条用户消息作为摘要
  def title
    ai_messages.find { |message| message.role == "user" }&.content.presence
  end

  # 当前对话回合的标识：触发该回合的用户消息。AI 建议块广播时携带它，
  # 编辑器据此丢弃迟到/过期回合的建议。
  def round_id
    ai_messages.where(role: "user").order(id: :desc).pick(:id)
  end
end
