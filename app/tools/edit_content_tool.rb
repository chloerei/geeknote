require_relative "ai_suggestion_broadcasting"

class EditContentTool < RubyLLM::Tool
  include AISuggestionBroadcasting

  description <<~DESC
    This tool proposes a batch of independent text edits for the current post content.
    Each edit replaces exactly one occurrence of old_text with new_text. Edits are only
    proposals: they are shown to the user as reviewable diff blocks and are never applied
    automatically.
    Requirements for every edit:
    - old_text must be non-empty, short, and match exactly one place in the content;
    - edits must not overlap each other or depend on another edit's new_text.
    If any edit fails these checks the whole call fails with an error and nothing is proposed.
    Read the content first with read_snapshot and anchor edits on the original text.
  DESC

  parameters do
    array :edits, min_items: 1,
      description: "List of edits. Every old_text must uniquely match the original content." do
      object do
        string :old_text,
          description: "The exact text to replace. Short, unique in the content, and independent from other edits."
        string :new_text, description: "The replacement text."
      end
    end
  end

  def initialize(chat)
    @chat = chat
  end

  def execute(edits:)
    content = @chat.snapshot["content"].to_s

    prepared = []
    edits.each_with_index do |raw, index|
      edit = prepare_edit(raw, index + 1, content)
      return edit if edit[:error]

      prepared << edit
    end

    if (overlap = overlapping_edits(prepared))
      return { error: "edit ##{overlap[:left]} overlaps edit ##{overlap[:right]}" }
    end

    blocks = prepared.map do |edit|
      { type: "replace", old_text: edit[:old_text], new_text: edit[:new_text] }
    end

    broadcast_ai_suggestions(blocks)
    { success: true, edits: blocks.length }
  end

  private

  # 返回 { old_text:, new_text:, from: }，或返回带 :error 的 Hash。
  def prepare_edit(raw, number, content)
    old_text = edit_value(raw, "old_text")
    new_text = edit_value(raw, "new_text")

    return { error: "edit ##{number}: old_text is empty" } if old_text.empty?

    occurrences = occurrence_positions(content, old_text)
    return { error: "edit ##{number}: old_text was not found in the content" } if occurrences.empty?
    if occurrences.length > 1
      return { error: "edit ##{number}: old_text matched #{occurrences.length} occurrences; make it unique" }
    end

    { old_text: old_text, new_text: new_text, from: occurrences.first }
  end

  def overlapping_edits(edits)
    ordered = edits.sort_by { |edit| edit[:from] }
    ordered.each_cons(2) do |left, right|
      next unless right[:from] < left[:from] + left[:old_text].length

      return { left: index_of(edits, left) + 1, right: index_of(edits, right) + 1 }
    end
    nil
  end

  def index_of(edits, target)
    edits.index { |edit| edit.equal?(target) }
  end

  def edit_value(raw, key)
    value = raw.is_a?(Hash) ? (raw[key] || raw[key.to_sym]) : nil
    value.to_s
  end

  # 返回所有非重叠匹配的起始位置。
  def occurrence_positions(content, needle)
    positions = []
    index = 0
    while (index = content.index(needle, index))
      positions << index
      index += needle.length
    end
    positions
  end
end
