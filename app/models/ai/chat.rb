class AI::Chat < ApplicationRecord
  acts_as_chat messages: :ai_messages, message_class: "AI::Message", messages_foreign_key: :ai_chat_id

  belongs_to :post
  belongs_to :user

  # The message a parked edit restarts from: recorded while a round is still
  # writing rows and consumed by that round's finish_round. Truncation clears
  # the marker in the same transaction, so an optional association suffices.
  belongs_to :restart_from_message,
    class_name: "AI::Message",
    optional: true

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

  # Deletes everything after +message+ and starts a fresh round from it. Runs
  # only once no job is writing rows: idle edits directly, parked edits in the
  # running round's finish_round.
  def restart_from!(message)
    transaction do
      ai_messages.where("id > ?", message.id).destroy_all
      update_columns(cancelled: false, processing: true, restart_from_message_id: nil)
    end
    AIChatResponseJob.perform_later(self)
  end
end
