import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dialog"
export default class extends Controller {
  connect() {
  }

  disconnect() {
    this.close()
  }

  open() {
    this.element.showModal()
  }

  close() {
    this.element.close()
  }

  backdropClose(event) {
    if (event.target === this.element) {
      this.close()
    }
  }
}
