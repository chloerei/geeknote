# 供写工具共用：把模型提议的修改块实时广播给前端。
# 建议块只描述"改什么"（锚点文本对），由编辑器渲染为可接受/拒绝的 diff 块，
# 服务端不做任何应用/持久化。
module AISuggestionBroadcasting
  private

  def broadcast_ai_suggestions(blocks)
    return if blocks.empty?

    Turbo::StreamsChannel.broadcast_action_to @chat,
      action: :ai_suggestion,
      attributes: { "round-id": @chat.round_id, blocks: JSON.generate(blocks) }
  end
end
