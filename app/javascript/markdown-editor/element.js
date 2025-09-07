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
    const inputElement = document.getElementById(this.getAttribute("input"))

    this.editElement = document.createElement("div")
    this.editElement.classList.add("edit")
    this.appendChild(this.editElement)

    this.previewElement = document.createElement("div")
    this.previewElement.classList.add("preview", "typography")
    this.previewElement.style.display = "none"
    this.appendChild(this.previewElement)

    this.markdownMirror = new MarkdownMirror({
      parent: this.editElement,
      input: inputElement,
      scrollMargin: { top: 0, bottom: 100 },
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
    this.editElement.remove()
    this.previewElement.remove()
  }

  focus() {
    this.markdownMirror.focus()
  }

  attachFile(file) {
    this.markdownMirror.attachFile(file)
  }

  async preview() {
    this.classList.add("fetching")

    const formData = new FormData()
    formData.append("content", this.markdownMirror.getValue())
    const response = await post("/preview", {
      body: formData
    })

    if (response.ok) {
      this.classList.remove("fetching")

      this.editElement.style.display = "none"
      this.previewElement.style.display = "block"

      const html = await response.html

      this.previewElement.innerHTML = html
    }
  }

  edit() {
    this.editElement.style.display = "block"
    this.previewElement.style.display = "none"
    this.previewElement.innerHTML = ""
  }
}

customElements.define("markdown-editor", MarkdownEditor)
