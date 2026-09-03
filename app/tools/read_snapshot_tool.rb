class ReadSnapshotTool < RubyLLM::Tool
  description "This tool reads the title and content for the current post."

  def initialize(chat)
    @chat = chat
  end

  def execute
    {
      title: @chat.snapshot["title"],
      content: @chat.snapshot["content"]
    }
  end
end
