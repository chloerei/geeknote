import { Controller } from "stimulus"

export default class extends Controller {
  click() {
    let scrollY = window.scrollY
    document.addEventListener('turbo:render', () => {
      window.scrollTo(0, scrollY)
    }, { once: true } )
  }
}
