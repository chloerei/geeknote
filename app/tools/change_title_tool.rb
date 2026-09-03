class ChangeTitleTool < RubyLLM::Tool
  description "Use this tool to modify the title of the current post. Do not use other tools to modify the title, and do not write the post title into the content."

  parameter :title, description: "The title of the snapshot."

  def initialize(chat)
    @chat = chat
  end

  def execute(title:)
    snapshot = { title: title, content: @chat.snapshot["content"] }

    if @chat.update(snapshot: snapshot)
      # The post editor listens for this action to live-preview the snapshot title.
      Turbo::StreamsChannel.broadcast_action_to @chat,
        action: :change_title,
        attributes: { title: title }
      { success: true }
    else
      { error: @chat.errors.full_messages.join(", ") }
    end
  end
end
