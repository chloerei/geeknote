import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    unsaveConfirm: "changes are not saved, are you sure to leave this page?"
  }

  connect() {
    this.element.addEventListener("input", () => {
      this.changed = true
    })

    this.element.addEventListener("turbo:submit-end", () => {
      this.changed = false
    })

    this.beforeUnloadListener = (event) => {
      if (this.changed) {
        event.preventDefault()
        event.returnValue = this.unsaveConfirmValue
        return this.unsaveConfirmValue
      }
    }

    window.addEventListener("beforeunload", this.beforeUnloadListener)

    this.beforeVisitListener = (event) => {
      if (this.changed) {
        if (!confirm(this.unsaveConfirmValue)) {
          event.preventDefault()
        }
      }
    }

    document.addEventListener("turbo:before-visit", this.beforeVisitListener)
  }

  disconnect() {
    window.removeEventListener("beforeunload", this.beforeUnloadListener)
    document.removeEventListener("turbo:before-visit", this.beforeVisitListener)
  }

  submit() {
    this.element.dispatchEvent(new CustomEvent('submit', { bubbles: true, cancelable: true }))
  }
}
