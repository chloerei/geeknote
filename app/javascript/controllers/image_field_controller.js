import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

// Connects to data-controller="image-field"
export default class extends Controller {
  static targets = [ "input", "signedIdInput", "preview" ]
  static values = { url: { type: String, default: "/rails/active_storage/direct_uploads" } }

  // Start a direct upload as soon as a file is picked, without waiting for form submit.
  upload() {
    const file = this.inputTarget.files[0]
    if (!file) return

    const upload = new DirectUpload(file, this.urlValue)
    upload.create((error, blob) => {
      if (error) {
        console.error(error)
        this.inputTarget.value = ''
        return
      }

      this.signedIdInputTarget.value = blob.signed_id
      this.signedIdInputTarget.disabled = false
      this.inputTarget.value = ''
      this.setPreview(URL.createObjectURL(file))
      this.element.classList.add('attached')
    })
  }

  // Clear the attachment: the signed-id input submits an empty value to detach it.
  remove() {
    this.signedIdInputTarget.value = ''
    this.signedIdInputTarget.disabled = false
    this.inputTarget.value = ''
    this.previewTarget.innerHTML = ''
    this.element.classList.remove('attached')
  }

  setPreview(url) {
    const img = document.createElement('img')
    img.src = url
    this.previewTarget.innerHTML = ''
    this.previewTarget.appendChild(img)
  }
}
