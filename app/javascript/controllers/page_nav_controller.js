import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  static classes = ["itemActive"]

  connect() {
    this.update()
  }

  update() {
    this.itemTargets.forEach((item) => {
      item.classList.toggle(this.itemActiveClass, item.href == document.location)
    })
  }
}
