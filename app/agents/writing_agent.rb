class WritingAgent < RubyLLM::Agent
  chat_model AI::Chat

  tools do
    [
      ReadPostTool.new(chat),
      WritePostTool.new(chat)
    ]
  end
end
