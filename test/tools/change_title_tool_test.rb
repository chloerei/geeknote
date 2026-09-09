require "test_helper"

class ChangeTitleToolTest < ActiveSupport::TestCase
  test "succeeds when the title differs and leaves the snapshot untouched" do
    chat = create(:ai_chat, snapshot: { "title" => "Old title", "content" => "Body" })
    create(:ai_message, ai_chat: chat, role: "user", content: "Better title")

    result = ChangeTitleTool.new(chat).execute(title: "New title")

    assert_equal({ success: true, changed: true }, result)
    assert_equal({ "title" => "Old title", "content" => "Body" }, chat.reload.snapshot)
  end

  test "reports unchanged when the title is the same" do
    chat = create(:ai_chat, snapshot: { "title" => "Same", "content" => "Body" })
    create(:ai_message, ai_chat: chat, role: "user", content: "Keep title")

    result = ChangeTitleTool.new(chat).execute(title: "Same")

    assert_equal({ success: true, changed: false }, result)
  end
end
