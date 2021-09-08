import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["item"]

  static classes = ["activeItem"]

  connect() {
    this.itemTargets.forEach((item) => {
      item.classList.toggle(this.activeItemClass, item.href == document.location)
    })
  }
}
