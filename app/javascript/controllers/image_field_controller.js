import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

// Connects to data-controller="image-field"
export default class extends Controller {
  static targets = [ "input", "signedIdInput", "preview", "progress" ]
  static values = { url: { type: String, default: "/rails/active_storage/direct_uploads" } }

  // Start a direct upload as soon as a file is picked, without waiting for form submit.
  upload() {
    const file = this.inputTarget.files[0]
    if (!file) return

    this.cancelled = false
    this.blobXhr = null
    this.fileXhr = null
    // Each upload bumps the generation counter; a callback only applies its
    // result if it still belongs to the latest generation. This guards against
    // a stale upload (canceled, or superseded by picking another file while the
    // previous one was still in flight) overriding newer state afterwards.
    this.generation = (this.generation || 0) + 1
    const generation = this.generation

    // Show the picked image right away, before the upload finishes.
    this.previousPreview = this.previewTarget.innerHTML
    this.previewUrl = URL.createObjectURL(file)
    this.setPreview(this.previewUrl)
    this.setUploading(true)

    const upload = new DirectUpload(file, this.urlValue, this)
    upload.create((error, blob) => {
      // Ignore stale callbacks: this upload was canceled, or superseded by a newer one.
      if (this.cancelled || generation !== this.generation) return

      if (error) {
        console.error(error)
        this.inputTarget.value = ''
        this.restorePreview()
        this.setUploading(false)
        return
      }

      this.signedIdInputTarget.value = blob.signed_id
      this.signedIdInputTarget.disabled = false
      this.inputTarget.value = ''
      this.previousPreview = null
      this.element.classList.add('attached')
      this.setUploading(false)
    })
  }

  // DirectUpload delegate: keep the blob-record XHR so cancel can abort it.
  directUploadWillCreateBlobWithXHR(request) {
    this.blobXhr = request
  }

  // DirectUpload delegate: keep the file-upload XHR and report progress.
  directUploadWillStoreFileWithXHR(request) {
    this.fileXhr = request
    request.upload.addEventListener('progress', (event) => {
      if (event.lengthComputable) {
        this.updateProgress(event.loaded / event.total)
      }
    })
  }

  // Abort the in-flight upload and restore the pre-upload state.
  cancel() {
    this.cancelled = true
    if (this.fileXhr) this.fileXhr.abort()
    if (this.blobXhr) this.blobXhr.abort()
    this.inputTarget.value = ''
    this.restorePreview()
    this.setUploading(false)
  }

  // Clear the attachment: the signed-id input submits an empty value to detach it.
  remove() {
    this.signedIdInputTarget.value = ''
    this.signedIdInputTarget.disabled = false
    this.inputTarget.value = ''
    this.previewTarget.innerHTML = ''
    this.element.classList.remove('attached')
  }

  setUploading(uploading) {
    this.element.classList.toggle('uploading', uploading)
    if (uploading) {
      this.updateProgress(0)
    }
  }

  updateProgress(ratio) {
    // The progress indicator is only present in the image/avatar field partials.
    if (this.hasProgressTarget) {
      this.progressTarget.textContent = Math.round(ratio * 100)
    }
  }

  // Roll the preview back to what was shown before the upload started.
  restorePreview() {
    if (this.previousPreview !== null) {
      if (this.previewUrl) URL.revokeObjectURL(this.previewUrl)
      this.previewTarget.innerHTML = this.previousPreview
      this.previousPreview = null
      this.previewUrl = null
    }
  }

  setPreview(url) {
    const img = document.createElement('img')
    img.src = url
    this.previewTarget.innerHTML = ''
    this.previewTarget.appendChild(img)
  }
}
