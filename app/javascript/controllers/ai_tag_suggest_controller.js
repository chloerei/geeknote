import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"
import { flashMessage } from "../lib/utils"

// Connects to data-controller="ai-tag-suggest"
//
// The sparkles button next to the tag field label asks the server for tag
// suggestions for the current draft and hands them to the tag field. The draft
// is read from the post editor inputs, so unsaved changes are taken into
// account; the suggestions are merged with the tags already there — those are
// never dropped, and the field ends up with at most +limit+ tags in total.
export default class extends Controller {
  static targets = [ "button", "icon", "spinner" ]
  static outlets = [ "tag-field" ]

  static values = {
    url: String,
    limit: { type: Number, default: 5 },
    empty: { type: String, default: "Write some content before asking for tags." },
    failure: { type: String, default: "Could not generate tag suggestions. Please try again." }
  }

  async suggest() {
    if (this.busy) return

    const content = document.getElementById("post_content")?.value.trim() || ""
    if (content === "") {
      flashMessage(this.emptyValue, "error")
      return
    }

    this.busy = true
    this.setBusy(true)

    try {
      const body = new FormData()
      body.append("title", document.getElementById("post_title")?.value || "")
      body.append("content", content)

      const response = await post(this.urlValue, { body })
      if (!response.ok) {
        flashMessage(this.failureValue, "error")
        return
      }

      const data = await response.json
      const tags = Array.isArray(data.tags) ? data.tags : []
      if (tags.length === 0) {
        flashMessage(this.failureValue, "error")
        return
      }

      this.tagFieldOutlet.addTags(tags, this.limitValue)
    } catch (error) {
      console.error(error)
      flashMessage(this.failureValue, "error")
    } finally {
      this.busy = false
      this.setBusy(false)
    }
  }

  setBusy(busy) {
    this.buttonTarget.disabled = busy
    this.iconTarget.classList.toggle("hidden", busy)
    // "hidden!" — daisyUI's .loading sets display, so the important modifier is
    // what actually keeps the spinner out of the way while idle.
    this.spinnerTarget.classList.toggle("hidden!", !busy)
  }
}
