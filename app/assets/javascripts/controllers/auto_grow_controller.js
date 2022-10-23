import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.resize()
    this.element.addEventListener('input', this.resize.bind(this))
  }

  resize() {
    this.element.style.height = 0
    this.element.style.height = this.element.scrollHeight + 'px'
  }
}
