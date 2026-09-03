class ReadSnapshotTool < RubyLLM::Tool
  description "This tool reads the snapshot for the current conversation. It returns the snapshot's title and content."

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
