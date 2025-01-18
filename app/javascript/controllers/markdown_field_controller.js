import { Controller } from "@hotwired/stimulus"
import { post } from '@rails/request.js'
import { MarkdownEditor } from "../lib/markdown-editor"

// Connects to data-controller="markdown-field"
export default class extends Controller {
  static targets = [ "contentInput", "contentMarkdown", "preview" ]

  static values = {
    autofocus: Boolean
  }

  connect() {
    this.markdownEditor = new MarkdownEditor({
      parent: this.contentMarkdownTarget,
      input: this.contentInputTarget
    })

    if (this.autofocusValue) {
      // wait for the next frame to focus
      setTimeout(() => {
        this.markdownEditor.focus()
      }, 0)
    }
  }

  disconnect() {
    this.markdownEditor.destroy()
  }

  reconnect(event) {
    this.disconnect()
    this.connect()
  }

  attachFile() {
    this.markdownEditor.attachFile()
  }

  async preview() {
    this.previewTarget.innerHTML = ""
    this.element.classList.add('previewing')

    const formData = new FormData()
    formData.append("content", this.contentInputTarget.value)
    const response = await post("/preview", {
      body: formData
    })

    if (response.ok) {
      const html = await response.html

      this.previewTarget.innerHTML = html
    }
  }

  write() {
    this.element.classList.remove("previewing")
  }

  focus() {
    this.markdownEditor.focus()
  }
}
