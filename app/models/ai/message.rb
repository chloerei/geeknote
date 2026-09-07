class AI::Message < ApplicationRecord
  acts_as_message chat: :ai_chat, chat_class: "AI::Chat"
  has_many_attached :attachments

  # Tool results render inside their parent tool-call card, never as standalone
  # list bubbles, so they are excluded from the paginated message list.
  scope :without_tool_results, -> { where.not(role: "tool") }

  after_create_commit :broadcast_message_created
  after_update_commit :broadcast_message_updated
  after_destroy_commit :broadcast_message_destroyed

  # Overrides the gem's to_partial_path: an assistant message that carries tool
  # calls still renders through the assistant partial, which shows its content
  # alongside the tool calls. Only role "tool" stays special.
  def to_partial_path
    "#{self.class.name.underscore.pluralize}/#{role.to_s.presence || "assistant"}"
  end

  def broadcast_append_chunk(content)
    broadcast_append_to ai_chat,
      target: "ai_message_#{id}_content",
      content: ERB::Util.html_escape(content.to_s)
  end

  # Thinking chunks stream into the raw target of the collapsed thinking card
  # (see ai/messages/_thinking), mirroring how content streams into the bubble.
  def broadcast_append_thinking_chunk(content)
    broadcast_append_to ai_chat,
      target: "ai_message_#{id}_thinking_content",
      content: ERB::Util.html_escape(content.to_s)
  end

  # Reasoning finished and the answer is starting: swap the whole live thinking
  # card (spinner icon, open) for its completed rendering (lightbulb icon,
  # collapsed). The caller persists the streamed reasoning text on the row first
  # so this render carries the full body (AIChatResponseJob#flush_content).
  def broadcast_thinking_finished
    broadcast_replace_later_to ai_chat,
      target: "ai_message_#{id}_thinking",
      partial: "ai/messages/thinking",
      locals: { message: self }
  end

  # Removes the empty thinking card when the model answers without emitting
  # any reasoning text at all.
  def broadcast_remove_empty_thinking_card
    broadcast_remove_to ai_chat, target: "ai_message_#{id}_thinking"
  end

  private

  # Rows are created as empty assistant shells and finalized (tool calls / role
  # "tool") by a later commit, so that final shape is broadcast on the update
  # too. Branching mirrors to_partial_path: only role "tool" rows are special —
  # their output lives inside the parent tool-call card instead of a list
  # bubble; every other row is appended on create and replaced on update.
  def broadcast_message_created
    if role == "tool"
      broadcast_tool_result_to_parent
    else
      broadcast_append_later_to ai_chat, target: "ai_messages"
    end
  end

  def broadcast_message_updated
    if role == "tool"
      broadcast_tool_result_to_parent
    else
      broadcast_replace_later_to ai_chat,
        target: "ai_message_#{id}",
        partial: to_partial_path,
        locals: { message: self }
    end
  end

  def broadcast_message_destroyed
    broadcast_action_later_to ai_chat, action: :remove, target: "ai_message_#{id}"
  end

  # Swaps the whole parent tool-call card for its completed rendering — spinner
  # icon and "running" placeholder give way to the tool icon and result in one
  # replace — then removes the bubble that announced this row's shell. The gem
  # persists the role change and parent link in one transaction, so by the time
  # this commit callback runs the has_one parent is current — no stale
  # association cache.
  def broadcast_tool_result_to_parent
    return unless tool_result?

    tool_call = ruby_llm_parent_tool_call
    broadcast_replace_later_to ai_chat,
      target: "ai_message_tool_call_#{tool_call.tool_call_id}",
      partial: "ai/messages/tool_call",
      locals: { tool_call_record: tool_call }
    broadcast_remove_announcing_bubble
  end

  def broadcast_remove_announcing_bubble
    broadcast_action_later_to ai_chat, action: :remove, target: "ai_message_#{id}"
  end
end
