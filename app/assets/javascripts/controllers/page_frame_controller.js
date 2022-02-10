import { Controller } from "@hotwired/stimulus"
import { Turbo } from '@hotwired/turbo-rails'

export default class extends Controller {
  update() {
    let url = new URL(this.element.src, window.location.origin)
    Turbo.navigator.history.push(url)
    this.element.dispatchEvent(new CustomEvent('page-frame:update', { bubbles: true, detail: { url: url } }))
  }
}
