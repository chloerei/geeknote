import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="snackbar"
export default class extends Controller {
  static show(message) {
    const html = `
      <div class="fixed bottom-4 left-4 z-10 pb-safe">
        <div class="snackbar" data-controller="snackbar" data-turbo-temporary>
          ${message}
        </div>
      </div>
    `
    document.body.insertAdjacentHTML('beforeend', html)
  }

  static values = {
    period: {
      type: Number,
      default: 5000
    }
  }

  connect() {
    setTimeout(() => this.remove(), this.periodValue)
  }

  remove() {
    this.element.classList.add('animate-slide-out-down')
    this.element.addEventListener('animationend', () => this.element.remove())
  }
}
