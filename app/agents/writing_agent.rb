class WritingAgent < RubyLLM::Agent
  chat_model AI::Chat

  tools do
    [
      ReadSnapshotTool.new(chat),
      ChangeTitleTool.new(chat),
      WriteContentTool.new(chat)
    ]
  end
end
