import { Controller } from "@hotwired/stimulus"
import { patch } from "@rails/request.js"

export default class extends Controller {
  updatePosition(event) {
    let formData = new FormData()
    formData.append('collection_item[position]', event.detail.position)
    patch(this.element.dataset.updateUrl, {
      body: formData
    })
  }
}
