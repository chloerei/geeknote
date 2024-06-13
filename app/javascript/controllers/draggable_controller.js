import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["handle"]

  connect() {
    if (this.handleTarget) {
      this.handleTarget.addEventListener('mousedown', () => {
        this.element.setAttribute('draggable', 'true')
      })

      this.handleTarget.addEventListener('mouseup', () => {
        this.element.removeAttribute('draggable')
      })
    }

    this.element.addEventListener('dragstart', () => {
      setTimeout(() => {
        this.element.classList.add('dragging')
      }, 1)
    })

    this.element.addEventListener('dragend', () => {
      this.element.classList.remove('dragging')

      if (this.handleTarget) {
        this.element.removeAttribute('draggable')
      }
    })
  }
}
