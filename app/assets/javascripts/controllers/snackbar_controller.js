import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const delay = parseInt(this.data.get('period')) || 5000

    setTimeout(() => {
      this.element.remove()
    }, delay)
  }
}
