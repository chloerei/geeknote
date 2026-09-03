class WritingAgent < RubyLLM::Agent
  chat_model AI::Chat

  tools do
    [
      ReadSnapshotTool.new(chat),
      WriteSnapshotTool.new(chat)
    ]
  end
end
