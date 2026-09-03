class WriteSnapshotTool < RubyLLM::Tool
  description "This tool writes content to the snapshot for the current conversation."

  parameter :title, description: "The title of the snapshot."
  parameter :content, description: "The content of the snapshot."

  def initialize(chat)
    @chat = chat
  end

  def execute(title:, content:)
    if @chat.update(snapshot: { title: title, content: content })
      # The post editor listens for this action to live-preview the snapshot draft.
      Turbo::StreamsChannel.broadcast_action_to @chat,
        action: :write_post,
        attributes: { title: title, content: content }
      { success: true }
    else
      { error: @chat.errors.full_messages.join(", ") }
    end
  end
end
