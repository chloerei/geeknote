import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autoresize"
export default class extends Controller {
  connect() {
    this.onInput = () => { this.resize() }
    this.resize()
    this.element.addEventListener('input', this.onInput)
  }

  disconnect() {
    this.element.removeEventListener('input', this.onInput)
  }

  resize() {
    this.element.style.height = 0
    this.element.style.height = (this.element.scrollHeight) + 'px'
  }
}
