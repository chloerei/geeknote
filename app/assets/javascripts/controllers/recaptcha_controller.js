import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (window.grecaptcha && window.grecaptcha.render && this.element.childElementCount == 0) {
      grecaptcha.render(this.element, {
        'sitekey' : this.element.dataset.sitekey
      })
    }
  }
}
