import { Controller } from "stimulus"
import { Turbo } from '@hotwired/turbo-rails'

export default class extends Controller {
  submit() {
    Turbo.navigator.submitForm(this.element)
  }
}
