import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comment-form"
export default class extends Controller {
  static outlets = [ "markdown-field" ]

  connect() {
  }

  focus() {
    this.markdownFieldOutlet.focus()
  }
}
