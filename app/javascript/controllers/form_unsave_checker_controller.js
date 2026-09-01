import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-unsave-checker"
export default class extends Controller {
  static targets = ["form"]

  static values = {
    unsave: Boolean,
    confirm: {
      type: String,
      default: "You have unsaved changes. Are you sure you want to leave?"
    }
  }

  connect() {
    this.handleInput = (event) => {
      if (this.belongsToForm(event.target) && event.target.hasAttribute("name")) {
        this.unsaveValue = true
      }
    }

    this.handleTurboSubmitEnd = (event) => {
      if (!this.hasFormTarget || event.detail.form === this.formTarget) {
        this.unsaveValue = false
      }
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

  // Only watch fields that belong to the form under watch. This covers inputs
  // nested in the form as well as fields associated with it via the `form`
  // attribute (e.g. the settings panel), while ignoring unrelated forms such
  // as the AI chat composer. Falls back to the whole controller element when
  // no form target is declared.
  belongsToForm(target) {
    return !this.hasFormTarget ||
      target.form === this.formTarget ||
      this.formTarget.contains(target)
  }
}
