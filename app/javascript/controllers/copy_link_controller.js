import { Controller } from "@hotwired/stimulus"
import { flashMessage } from "../lib/utils"

// Connects to data-controller="copy-link"
export default class extends Controller {
  static values = {
    url: String
  }

  copy() {
    const url = new URL(this.urlValue, window.location.origin)
    navigator.clipboard.writeText(url)
    this.element.blur()
    flashMessage("Link copied to clipboard", "success")
  }
}
