import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview", "input", "removeCheckbox"]

  update(event) {
    let file = event.target.files[0]
    if (file) {
      let image = document.createElement('img')
      image.src = URL.createObjectURL(file)
      this.previewTarget.innerHTML = ''
      this.previewTarget.appendChild(image)
      this.removeCheckboxTarget.checked = false
      this.element.classList.add('image-uploader--active')
    }
  }

  remove() {
    this.previewTarget.innerHTML = ''
    this.inputTarget.value = ''
    this.element.classList.remove('image-uploader--active')
  }
}
