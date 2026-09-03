import { Turbo } from "@hotwired/turbo-rails"

// Sync the post editor when the AI edits snapshot content via the edit_content tool
Turbo.StreamActions.edit_content = function () {
  const editor = document.querySelector("markdown-editor")
  if (!editor) return

  const oldText = this.getAttribute("old-text")
  const newText = this.getAttribute("new-text")
  if (oldText === null || newText === null) return

  editor.markdownMirror?.findAndReplace(oldText, newText, {
    replaceAll: this.getAttribute("replace-all") === "true",
    highlight: true
  })
}
