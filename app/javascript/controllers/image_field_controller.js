import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-field"
export default class extends Controller {
  static targets = [ "input", "preview", "removeInput" ]

  connect() {
    this.form = this.element.closest('form')
    this.form.addEventListener('turbo:submit-end', (event) => {
      // avoid repeated submit after morphing
      if (event.detail.success) {
        this.inputTarget.value = ''
      }
    })
  }

  preview() {
    const img = document.createElement('img')
    img.src = URL.createObjectURL(this.inputTarget.files[0])
    this.previewTarget.innerHTML = ''
    this.previewTarget.appendChild(img)
    this.removeInputTarget.checked = false
    this.element.classList.add('attached')
  }

  remove() {
    this.inputTarget.value = ''
    this.previewTarget.innerHTML = ''
    this.element.classList.remove('attached')
  }
}
