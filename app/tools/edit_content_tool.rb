class EditContentTool < RubyLLM::Tool
  description <<~DESC
    This tool replaces a text inside the snapshot content for the current conversation.
    Unlike write_content, which ignores the original content and replaces it entirely,
    edit_content only modifies the parts that match old_text.
  DESC

  parameter :old_text, description: "The exact text to find in the snapshot content."
  parameter :new_text, description: "The text to replace old_text with."
  parameter :replace_all, type: :boolean,
    description: "Replace every occurrence when true; otherwise the first.",
    required: false

  def initialize(chat)
    @chat = chat
  end

  def execute(old_text:, new_text:, replace_all: false)
    content = @chat.snapshot["content"].to_s

    if old_text.empty? || !content.include?(old_text)
      return { error: "old_text was not found in the snapshot content" }
    end

    new_content = if replace_all
      content.gsub(old_text) { new_text }
    else
      content.sub(old_text) { new_text }
    end

    if @chat.update(snapshot: { title: @chat.snapshot["title"], content: new_content })
      Turbo::StreamsChannel.broadcast_action_to @chat,
        action: :edit_content,
        attributes: { "old-text": old_text, "new-text": new_text, "replace-all": replace_all }
      { success: true }
    else
      { error: @chat.errors.full_messages.join(", ") }
    end
  end
end
