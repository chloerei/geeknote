import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="recaptcha"
export default class extends Controller {
  connect() {
    this.render()
  }

  render() {
    if (window.grecaptcha && window.grecaptcha.render) {
      if (this.widgetId !== undefined) {
        grecaptcha.reset(this.widgetId)
      } else {
        this.widgetId = grecaptcha.render(this.element, {
          'sitekey' : this.element.dataset.sitekey
        })
      }
    }
  }
}
