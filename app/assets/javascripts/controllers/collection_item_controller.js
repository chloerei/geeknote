import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {
  updatePosition(event) {
    let formData = new FormData()
    formData.append('collection_item[position]', event.detail.position)
    Rails.ajax({
      url: this.element.dataset.updateUrl,
      data: formData,
      type: 'patch'
    })
  }
}
