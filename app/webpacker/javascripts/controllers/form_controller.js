import { Controller } from "stimulus"
import { Turbo } from '@hotwired/turbo-rails'

export default class extends Controller {
  submit() {
    // this.element.dispatchEvent(new Event('submit', { bubbles: true }))
    Turbo.navigator.submitForm(this.element)
  }
}
