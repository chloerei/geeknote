import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ai-suggestion-bar"
//
// A bar in the chat panel offering "accept all / reject all" for the pending AI
// suggestions. It is a remote control for the post editor: the editor reports
// the pending count through the "ai-suggestions:changed" document event and
// exposes acceptAllSuggestions() / rejectAllSuggestions() on <markdown-editor>.
export default class extends Controller {
  static targets = [ "bar", "count" ]

  connect() {
    this.onSuggestionsChanged = this.onSuggestionsChanged.bind(this)
    document.addEventListener("ai-suggestions:changed", this.onSuggestionsChanged)
  }

  disconnect() {
    document.removeEventListener("ai-suggestions:changed", this.onSuggestionsChanged)
  }

  onSuggestionsChanged(event) {
    const count = event.detail?.count || 0
    this.barTarget.hidden = count === 0
    this.countTarget.textContent = String(count)
  }

  acceptAll() {
    document.querySelector("markdown-editor")?.acceptAllSuggestions()
  }

  rejectAll() {
    document.querySelector("markdown-editor")?.rejectAllSuggestions()
  }
}
