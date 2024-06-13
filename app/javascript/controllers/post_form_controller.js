import { Controller } from "@hotwired/stimulus"

const isMac = /Mac/.test(navigator.platform)

export default class extends Controller {
  static values = {
    unsaveConfirm: "changes are not saved, are you sure to leave this page?"
  }

  connect() {
    let changeCallback = (event) => {
      if (event.target.hasAttribute('name')) {
        this.changed = true
        this.element.removeEventListener("change", changeCallback)
      }
    }

    this.element.addEventListener("change", changeCallback)

    this.element.addEventListener("turbo:submit-end", () => {
      this.changed = false
      this.element.addEventListener("change", changeCallback)
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

    this.onKeydownHandler = this.onKeydown.bind(this)
    document.addEventListener('keydown', this.onKeydownHandler)
  }

  disconnect() {
    window.removeEventListener("beforeunload", this.beforeUnloadListener)
    document.removeEventListener("turbo:before-visit", this.beforeVisitListener)
    document.removeEventListener('keydown', this.onKeydownHandler)
  }

  submit() {
    this.element.dispatchEvent(new CustomEvent('submit', { bubbles: true, cancelable: true }))
  }

  onKeydown(event) {
    if (isMac) {
      if (event.key == 's' && event.metaKey) {
        event.preventDefault()
        this.submit()
      }
    } else {
      if (event.key == 's' && event.ctrlKey) {
        event.preventDefault()
        this.submit()
      }
    }
  }
}
