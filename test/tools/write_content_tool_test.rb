require "test_helper"

class WriteContentToolTest < ActiveSupport::TestCase
  test "succeeds for the new content and leaves the snapshot untouched" do
    chat = create(:ai_chat, snapshot: { "title" => "Draft", "content" => "Old body" })
    create(:ai_message, ai_chat: chat, role: "user", content: "Rewrite it")

    result = WriteContentTool.new(chat).execute(content: "Fresh body")

    assert_equal({ success: true, changed: true }, result)
    assert_equal({ "title" => "Draft", "content" => "Old body" }, chat.reload.snapshot)
  end

  test "reports unchanged when the content is the same" do
    chat = create(:ai_chat, snapshot: { "title" => "Draft", "content" => "Same body" })
    create(:ai_message, ai_chat: chat, role: "user", content: "Keep it")

    result = WriteContentTool.new(chat).execute(content: "Same body")

    assert_equal({ success: true, changed: false }, result)
  end

  test "rejects empty content" do
    chat = create(:ai_chat, snapshot: { "title" => "Draft", "content" => "Body" })
    create(:ai_message, ai_chat: chat, role: "user", content: "Rewrite it")

    result = WriteContentTool.new(chat).execute(content: "   ")

    assert_equal({ error: "content is empty" }, result)
  end
end
