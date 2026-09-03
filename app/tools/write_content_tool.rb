class WriteContentTool < RubyLLM::Tool
  description "This tool writes content to the snapshot for the current conversation."

  parameter :content, description: "The content of the snapshot."

  def initialize(chat)
    @chat = chat
  end

  def execute(content:)
    snapshot = { title: @chat.snapshot["title"], content: content }

    if @chat.update(snapshot: snapshot)
      # The post editor listens for this action to live-preview the snapshot content.
      Turbo::StreamsChannel.broadcast_action_to @chat,
        action: :write_content,
        attributes: { content: content }
      { success: true }
    else
      { error: @chat.errors.full_messages.join(", ") }
    end
  end
end
