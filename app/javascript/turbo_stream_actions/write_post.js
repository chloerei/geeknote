import { Turbo } from "@hotwired/turbo-rails"

// Sync the post editor when the AI writes to the post via the write_post tool
Turbo.StreamActions.write_post = function () {
  const editor = document.querySelector("markdown-editor")
  if (!editor) return

  const title = this.getAttribute("title")
  if (title !== null) {
    const titleInput = document.getElementById("post_title")
    if (titleInput) titleInput.value = title
  }

  const content = this.getAttribute("content")
  if (content !== null) {
    editor.markdownMirror?.setContent(content, { highlight: true })
  }
}
