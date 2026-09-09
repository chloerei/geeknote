import { Turbo } from "@hotwired/turbo-rails"

// Forward AI tool suggestion blocks to the post editor. Each block is an
// anchored text change the user can review (accept / reject) inline. The
// editor decides per round; blocks carry the user message id they belong to.
Turbo.StreamActions.ai_suggestion = function () {
  const editor = document.querySelector("markdown-editor")
  if (!editor) return

  const blocksRaw = this.getAttribute("blocks")
  if (!blocksRaw) return

  editor.showAiSuggestion({
    roundId: this.getAttribute("round-id"),
    blocks: JSON.parse(blocksRaw)
  })
}
