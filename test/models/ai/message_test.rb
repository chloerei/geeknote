require "test_helper"

class AI::MessageTest < ActiveSupport::TestCase
  # Regression: a streamed row is created as an assistant shell (appended to
  # the list) and, when it turns out to be a tool result, removed again. Both
  # broadcasts must arrive in that order, so the append cannot go through
  # SolidQueue where concurrent workers could let the remove overtake it and
  # leave a stray bubble rendering the raw tool result.
  test "appends an assistant shell before removing it as a tool result" do
    chat = create(:ai_chat)
    caller = create(:ai_message, ai_chat: chat, role: "assistant", content: "calling a tool")

    shell = nil
    streams = capture_turbo_stream_broadcasts(chat) do
      shell = create(:ai_message, ai_chat: chat, role: "assistant", content: "")

      caller.ruby_llm_tool_calls.create!(
        tool_call_id: "call_regression_1",
        name: "edit_content",
        result: shell
      )

      shell.update!(role: "tool")
    end

    actions = streams.map { |stream| [ stream["action"], stream["target"] ] }

    append_index = actions.index([ "append", "ai_messages" ])
    remove_index = actions.index([ "remove", "ai_message_#{shell.id}" ])

    assert_not_nil append_index, "expected the shell to be appended synchronously"
    assert_not_nil remove_index, "expected the announcing bubble to be removed"
    assert_operator append_index, :<, remove_index
  end
end
