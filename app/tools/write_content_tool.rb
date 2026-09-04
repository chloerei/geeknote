require_relative "ai_suggestion_broadcasting"

class WriteContentTool < RubyLLM::Tool
  include AISuggestionBroadcasting

  description <<~DESC
    This tool proposes replacing the entire content of the current post with a new text.
    It is offered to the user as a single whole-document rewrite suggestion for review and
    is never applied automatically. Prefer edit_content for localized improvements; use
    write_content only when the user asked for a rewrite of the whole article or a broad
    restructure.
  DESC

  parameter :content, description: "The proposed full content (Markdown)."

  def initialize(chat)
    @chat = chat
  end

  def execute(content:)
    return { error: "content is empty" } if content.blank?

    if content == @chat.snapshot["content"]
      return { success: true, changed: false }
    end

    broadcast_ai_suggestions([ { type: "rewrite", new_text: content } ])
    { success: true, changed: true }
  end
end
