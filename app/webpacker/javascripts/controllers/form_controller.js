import { Controller } from "stimulus"
import { Turbo } from '@hotwired/turbo-rails'

export default class extends Controller {
  submit() {
    this.element.dispatchEvent(new CustomEvent('submit', { bubbles: true, cancelable: true }))
  }
}
