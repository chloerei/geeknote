require_relative "ai_suggestion_broadcasting"

class ChangeTitleTool < RubyLLM::Tool
  include AISuggestionBroadcasting

  description "Sets a new title for the current post. Unlike content edits, a title change is applied immediately without user review. Do not use other tools to modify the title, and do not write the post title into the content."

  parameter :title, description: "The proposed title."

  def initialize(chat)
    @chat = chat
  end

  def execute(title:)
    return { success: true, changed: false } if title.to_s == @chat.snapshot["title"].to_s

    broadcast_ai_suggestions([ { type: "title", new_title: title.to_s } ])
    { success: true, changed: true }
  end
end
