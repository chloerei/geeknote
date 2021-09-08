import { Controller } from "stimulus"
import { Turbo } from '@hotwired/turbo-rails'

export default class extends Controller {
  static targets = ["navItem", "frame"]

  static classes = ["navItemActive"]

  update() {
    let src = this.frameTarget.src
    if (src) {
      this.navItemTargets.forEach((item) => {
        item.classList.toggle(this.navItemActiveClass, item.href == src)
      })

      let url = new URL(this.frameTarget.src)
      Turbo.navigator.history.replace(url)
    }
  }
}
