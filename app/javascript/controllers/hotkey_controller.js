import { Controller } from "@hotwired/stimulus"
import { install, uninstall, eventToHotkeyString, normalizeHotkey } from "@github/hotkey"
import { isFormField } from "@github/hotkey/dist/utils.js"

// Connects to data-controller="hotkey"
export default class extends Controller {
  connect() {
    if (this.element.hasAttribute("data-hotkey-global")) {
      this.keydownHandler = (event) => {
        const hotkey = eventToHotkeyString(event)
        const targetHotkey = normalizeHotkey(this.element.getAttribute("data-hotkey"))
        if (hotkey === targetHotkey) {
          event.preventDefault()
          if (isFormField(this.element)) {
            this.element.focus()
          } else {
            this.element.click()
          }
        }
      }
      document.addEventListener("keydown", this.keydownHandler)
    } else {
      install(this.element)
    }
  }

  disconnect() {
    if (this.keydownHandler) {
      document.removeEventListener("keydown", this.keydownHandler)
    } else {
      uninstall(this.element)
    }
  }
}
