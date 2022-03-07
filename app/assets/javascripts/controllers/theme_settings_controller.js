import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const colorScheme = localStorage.getItem('color_scheme') || 'default'
    const input = this.element.querySelector(`input[name="color_scheme"][value="${colorScheme}"]`)
    if (input) {
      input.checked = true
    }
  }

  selectColorScheme(event) {
    localStorage.setItem('color_scheme', event.target.value)
    document.body.dataset.colorScheme = event.target.value
  }
}
