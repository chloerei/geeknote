import { Controller } from "stimulus"
import { Editor } from "../lib/editor"
import { DirectUpload } from "@rails/activestorage"
import { Turbo } from '@hotwired/turbo-rails'

export default class extends Controller {
  static values = {
    directUploadUrl: String
  }

  static targets = ['form', 'contentEditor', 'contentInput']

  connect() {
    this.initEditor()
    window.Turbo = Turbo

    this.formTarget.addEventListener('turbo:submit-end', this.submitEnd.bind(this))
  }

  initEditor() {
    const directUploadUrl = this.directUploadUrlValue
    this.editor = new Editor(this.contentEditorTarget, {
      input: this.contentInputTarget,
      uploadImage: (file) => {
        return new Promise(function(resolve, reject) {
          const upload = new DirectUpload(file, directUploadUrl)
          upload.create((error, blob) => {
            if (error) {

            } else {
              resolve(`/attachments/${blob.key}/${blob.filename}`)
            }
          })
        })
      }
    })
  }

  submitEnd(event) {
    let response = event.detail.fetchResponse.response
    if (response.ok) {
      const location = response.headers.get('Location')
      if (location) {
        let url = new URL(location)
        Turbo.navigator.history.replace(url)
        this.formTarget.setAttribute('action', url.pathname)
        let methodInput = document.createElement('input')
        methodInput.type = 'hidden'
        methodInput.name = '_method'
        methodInput.value = 'PUT'
        this.formTarget.appendChild(methodInput)
      }
    } else {
      // TODO: errror notice and save local
    }

  }
}
