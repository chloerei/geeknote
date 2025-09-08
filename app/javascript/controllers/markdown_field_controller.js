import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="markdown-field"
export default class extends Controller {
  static targets = [ "markdownEditor" ]

  connect() {
  }

  disconnect() {
  }

  attachFile() {
    const input = document.createElement('input')
    input.type = 'file'
    input.accept = 'image/png, image/gif, image/jpeg, image/svg+xml, video/mp4, video/quicktime, video/webm'
    input.multiple = true
    input.onchange = (event) => {
      Array.from(event.target.files).forEach(file => {
        this.markdownEditorTarget.attachFile(file)
      })
    }
    input.click()
  }

  preview() {
    this.markdownEditorTarget.preview()
    this.element.classList.add("previewing")
  }

  edit() {
    this.markdownEditorTarget.edit()
    this.element.classList.remove("previewing")
  }

  focus() {
    this.markdownEditorTarget.focus()
  }
}
