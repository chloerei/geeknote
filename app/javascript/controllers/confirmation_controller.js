import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="confirmation"
// Generic "type-to-confirm" behavior for destructive forms: the submit button
// stays disabled until the input value matches the required value exactly.
// Usage:
//   <div data-controller="confirmation" data-confirmation-required-value="foo">
//     <input data-confirmation-target="input" data-action="input->confirmation#update">
//     <button data-confirmation-target="submit" disabled>Confirm</button>
//   </div>
export default class extends Controller {
  static targets = ["input", "submit"]
  static values = { required: String }

  connect() {
    this.update()
  }

  update() {
    this.submitTarget.disabled = this.inputTarget.value.trim() !== this.requiredValue
  }
}
