import { Controller } from "@hotwired/stimulus"
import { post } from '@rails/request.js'
import { MarkdownEditor } from "../lib/markdown-editor"

// Connects to data-controller="markdown-field"
export default class extends Controller {
  static targets = [ "contentInput", "markdownEditor", "editButton", "previewButton", "toolbarButton" ]

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
    this.editButtonTarget.classList.remove("button--active")
    this.previewButtonTarget.classList.add("button--active")
    this.toolbarButtonTargets.forEach(button => {
      button.disabled = true
    })
  }

  write() {
    this.markdownEditorTarget.edit()
    this.previewButtonTarget.classList.remove("button--active")
    this.editButtonTarget.classList.add("button--active")
    this.toolbarButtonTargets.forEach(button => {
      button.disabled = false
    })
  }

  focus() {
    this.markdownEditorTarget.focus()
  }
}
