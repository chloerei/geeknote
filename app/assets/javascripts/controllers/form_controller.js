import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    this.element.dispatchEvent(new CustomEvent('submit', { bubbles: true, cancelable: true }))
  }
}
