import { Turbo } from "@hotwired/turbo-rails"

// Sync the post editor when the AI writes to the snapshot via the write_content tool
Turbo.StreamActions.write_content = function () {
  const editor = document.querySelector("markdown-editor")
  if (!editor) return

  const content = this.getAttribute("content")
  if (content !== null) {
    editor.markdownMirror?.setContent(content, { highlight: true })
  }
}
