import { Controller } from "stimulus"

export default class extends Controller {
  submit() {
    this.element.dispatchEvent(new Event('submit', { bubbles: true }))
  }
}
