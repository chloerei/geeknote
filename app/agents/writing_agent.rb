class WritingAgent < RubyLLM::Agent
  chat_model AI::Chat

  tools do
    [
      ReadPostTool.new(chat.post),
      WritePostTool.new(chat.post)
    ]
  end
end
