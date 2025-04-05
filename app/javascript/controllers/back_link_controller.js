import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="back-link"
export default class extends Controller {
  connect() {
    this.element.addEventListener("click", this.handleClick)
  }

  handleClick(event) {
    if (window.Turbo.navigator.history.currentIndex > 0) {
      event.preventDefault()
      window.history.back()
    }
  }
}
