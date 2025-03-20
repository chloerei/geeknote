import { MarkdownMirror } from "./mirror"
import { DirectUpload } from "@rails/activestorage"
import { post } from '@rails/request.js'

const acceptFileTypes = [
  'image/png',
  'image/gif',
  'image/jpeg',
  'image/svg+xml',
  'video/mp4',
  'video/quicktime',
  'video/webm'
]

const acceptFileSize = 10 * 1024 * 1024

class MarkdownEditor extends HTMLElement {
  static observedAttributes = ["input"]

  constructor() {
    super()
  }

  connectedCallback() {
    this.inputElement = document.getElementById(this.getAttribute("input"))

    this.markdownMirror = new MarkdownMirror({
      parent: this,
      input: this.inputElement,
      onFileAccept: (file) => {
        return acceptFileTypes.includes(file.type) && file.size <= acceptFileSize
      },
      onFileAttach: (file, successCallback) => {
        const upload = new DirectUpload(file, "/rails/active_storage/direct_uploads")
        upload.create(async (error, blob) => {
          if (error) {
            console.error(error)
          } else {
            let formData = new FormData()
            formData.append('attachment[file]', blob.signed_id)
            const response = await post('/attachments', {
                body: formData
              }
            )
            if (response.ok) {
              const data = await response.json
              successCallback({ name: data.filename, url: data.url })
            }
          }
        })
      }
    })
  }

  disconnectedCallback() {
    this.markdownMirror.destroy()
    this.markdownMirror = null
  }

  focus() {
    this.markdownMirror.focus()
  }

  attachFile(file) {
    this.markdownMirror.attachFile(file)
  }
}

customElements.define("markdown-editor", MarkdownEditor)
