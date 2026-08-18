class AI::Chat < ApplicationRecord
  acts_as_chat messages: :ai_messages, message_class: 'AI::Message', messages_foreign_key: :ai_chat_id
end
