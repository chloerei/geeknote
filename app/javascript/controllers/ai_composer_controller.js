import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ai-composer"
//
// The composer is used both inside the post editor drawer and on standalone AI
// chat pages. When the post editor is present (it exposes #post_title and
// #post_content inputs), capture the current draft and submit it along with the
// message as snapshot[title] / snapshot[content] so the chat stores a snapshot.
export default class extends Controller {
  snapshot() {
    // Sending a new message means the round restarts from the current editor
    // content: discard any still pending AI suggestions.
    document.querySelector("markdown-editor")?.rejectAllSuggestions()

    const titleInput = document.getElementById("post_title")
    const contentInput = document.getElementById("post_content")

    // Snapshot params always carry title and content together, so capture only
    // when both fields exist (i.e. the composer is on the post editor page).
    if (!titleInput || !contentInput) return

    this.syncField("snapshot[title]", titleInput.value)
    this.syncField("snapshot[content]", contentInput.value)
  }

  syncField(name, value) {
    let input = this.element.querySelector(`input[name="${name}"]`)

    if (!input) {
      input = document.createElement("input")
      input.type = "hidden"
      input.name = name
      this.element.append(input)
    }

    input.value = value
  }
}
