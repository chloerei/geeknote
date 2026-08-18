module AI::MessagesHelper
  def tool_result_partial(message)
    name = message.respond_to?(:parent_tool_call) ? message.parent_tool_call&.name.to_s : ""
    partial_for(prefix: "ai/messages/tool_results", name: name)
  end

  def tool_call_partial(tool_call)
    partial_for(prefix: "ai/messages/tool_calls", name: tool_call.name.to_s)
  end

  private

  def partial_for(prefix:, name:)
    normalized = name.to_s.underscore.tr("-", "_")
    if normalized.present? && lookup_context.exists?(normalized, [ prefix ], true)
      "#{prefix}/#{normalized}"
    else
      "#{prefix}/default"
    end
  end
end
