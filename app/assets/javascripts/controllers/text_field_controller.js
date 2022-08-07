import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static values = {
    validateUrl: String,
    errorKey: String
  }

  static targets = ["helperText", "input"]

  connect() {
    this.OrignalHelperText = this.helperTextTarget.textContent
  }

  async validate() {
    if (this.validateUrlValue) {
      let data = new FormData()
      data.append(this.inputTarget.name, this.inputTarget.value)

      const response = await post(this.validateUrlValue, {
        body: data
      })

      if (response.ok) {
        const json = await response.json
        const errors = json['errors'][this.errorKeyValue]

        if (errors && errors.length) {
          this.element.classList.add('text-field--error')
          this.helperTextTarget.textContent = errors[0]
        } else {
          this.element.classList.remove('text-field--error')
          this.helperTextTarget.textContent = this.OrignalHelperText
        }
      }
    }
  }
}
