require "test_helper"

class EditContentToolTest < ActiveSupport::TestCase
  test "applies every edit point and leaves the snapshot untouched" do
    chat = create(:ai_chat, snapshot: { "title" => "Draft", "content" => "Hello world. Goodbye moon." })
    create(:ai_message, ai_chat: chat, role: "user", content: "Polish the text")

    result = EditContentTool.new(chat).execute(
      edits: [
        { "old_text" => "Hello world", "new_text" => "Hi there" },
        { "old_text" => "Goodbye moon", "new_text" => "Farewell stars" }
      ]
    )

    assert_equal({ success: true, edits: 2 }, result)
    assert_equal({ "title" => "Draft", "content" => "Hello world. Goodbye moon." }, chat.reload.snapshot)
  end

  test "accepts symbol keyed edits like string keyed ones" do
    chat = create(:ai_chat, snapshot: { "title" => "Draft", "content" => "Hello world." })
    create(:ai_message, ai_chat: chat, role: "user", content: "Fix it")

    result = EditContentTool.new(chat).execute(edits: [ { old_text: "Hello", new_text: "Hi" } ])

    assert_equal({ success: true, edits: 1 }, result)
  end

  test "fails the whole call when old_text is missing" do
    chat = create(:ai_chat, snapshot: { "title" => "Draft", "content" => "Hello world." })
    create(:ai_message, ai_chat: chat, role: "user", content: "Fix it")

    result = EditContentTool.new(chat).execute(
      edits: [
        { "old_text" => "Hello", "new_text" => "Hi" },
        { "old_text" => "nope", "new_text" => "missing" }
      ]
    )

    assert_equal({ error: "edit #2: old_text was not found in the content" }, result)
  end

  test "rejects ambiguous old_text and names the occurrence count" do
    chat = create(:ai_chat, snapshot: { "title" => "Draft", "content" => "abc def abc" })
    create(:ai_message, ai_chat: chat, role: "user", content: "Fix it")

    result = EditContentTool.new(chat).execute(edits: [ { "old_text" => "abc", "new_text" => "xyz" } ])

    assert_equal({ error: "edit #1: old_text matched 2 occurrences; make it unique" }, result)
  end

  test "rejects empty old_text" do
    chat = create(:ai_chat, snapshot: { "title" => "Draft", "content" => "Hello world." })
    create(:ai_message, ai_chat: chat, role: "user", content: "Fix it")

    result = EditContentTool.new(chat).execute(edits: [ { "old_text" => "", "new_text" => "x" } ])

    assert_equal({ error: "edit #1: old_text is empty" }, result)
  end

  test "rejects edits that overlap each other" do
    chat = create(:ai_chat, snapshot: { "title" => "Draft", "content" => "a quick brown fox" })
    create(:ai_message, ai_chat: chat, role: "user", content: "Fix it")

    result = EditContentTool.new(chat).execute(
      edits: [
        { "old_text" => "quick brown", "new_text" => "slow" },
        { "old_text" => "brown", "new_text" => "red" }
      ]
    )

    assert_equal({ error: "edit #1 overlaps edit #2" }, result)
  end
end
