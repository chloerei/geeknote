import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-unsave-checker"
export default class extends Controller {
  static values = {
    unsave: Boolean,
    confirm: {
      type: String,
      default: "You have unsaved changes. Are you sure you want to leave?"
    }
  }

  connect() {
    this.handleInput = (event) => {
      this.unsaveValue = true
    }

    this.handleTurboSubmitEnd = () => {
      this.unsaveValue = false
    }

    this.handleBeforeunload = (event) => {
      if (this.unsaveValue) {
        event.preventDefault()
        event.returnValue = this.confirmValue;
      }
    }

    this.handleTurboBeforevisit = (event) => {
      if (this.unsaveValue) {
        if (!confirm(this.confirmValue)) {
          event.preventDefault();
        }
      }
    }

    this.element.addEventListener("input", this.handleInput)
    this.element.addEventListener("turbo:submit-end", this.handleTurboSubmitEnd)
    window.addEventListener("beforeunload", this.handleBeforeunload)
    window.addEventListener("turbo:before-visit", this.handleTurboBeforevisit)
  }

  disconnect() {
    this.unsaveValue = false
    this.element.removeEventListener("input", this.handleInput)
    this.element.removeEventListener("turbo:submit-end", this.handleTurboSubmitEnd)
    window.removeEventListener("beforeunload", this.handleBeforeunload)
    window.removeEventListener("turbo:before-visit", this.handleBeforevisit)
  }
}
