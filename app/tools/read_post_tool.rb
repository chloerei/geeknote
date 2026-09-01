class ReadPostTool < RubyLLM::Tool
  description "This tool reads a post for current convesation. It returns the post's content and metadata."

  def initialize(chat)
    @chat = chat
  end

  def execute
    {
      title: @chat.post.title,
      content: @chat.post.content
    }
  end
end
