import { Controller } from "@hotwired/stimulus"

// Lets the user pick light / dark / system ("system" follows the OS). The
// choice is stored in localStorage so it is per device. "system" is
// represented by leaving <html data-theme> unset, which lets the CSS follow
// the OS setting.
const STORAGE_KEY = "theme"
const MODES = ["light", "dark", "system"]

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.mode = this.readMode()
    this.syncInputs()
    this.apply()
  }

  select(event) {
    this.mode = event.target.value
    try {
      localStorage.setItem(STORAGE_KEY, this.mode)
    } catch (e) {
      // Ignore storage failures (e.g. private mode); the theme still applies.
    }
    this.apply()
  }

  readMode() {
    try {
      const value = localStorage.getItem(STORAGE_KEY)
      return MODES.includes(value) ? value : "system"
    } catch (e) {
      return "system"
    }
  }

  syncInputs() {
    this.inputTargets.forEach((input) => {
      input.checked = input.value === this.mode
    })
  }

  apply() {
    if (this.mode === "system") {
      document.documentElement.removeAttribute("data-theme")
    } else {
      document.documentElement.dataset.theme = this.mode
    }
  }
}
