class WritePostTool < RubyLLM::Tool
  description "This tool writes content to the post for the current conversation."

  parameter :title, description: "The title of the post."
  parameter :content, description: "The content of the post."

  def initialize(chat)
    @chat = chat
  end

  def execute(title:, content:)
    if @chat.post.update(title: title, content: content)
      Turbo::StreamsChannel.broadcast_action_to @chat,
        action: :write_post,
        attributes: { title: title, content: content }
      { success: true }
    else
      { error: @chat.post.errors.full_messages.join(", ") }
    end
  end
end
