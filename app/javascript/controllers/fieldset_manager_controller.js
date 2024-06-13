import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["switch", "fieldset"]

  connect() {
    this.toggle()
  }

  toggle() {
    this.fieldsetTarget.disabled = !this.switchTarget.checked
  }
}
