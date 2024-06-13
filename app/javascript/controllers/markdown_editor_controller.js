import { Controller } from "@hotwired/stimulus"
import { post } from '@rails/request.js'
import { MarkdownEditor } from "lib/markdown-editor"

export default class extends Controller {
  static targets = ["input", "content", "preview"]

  connect() {
    this.markdownEditor = new MarkdownEditor({
      parent: this.contentTarget,
      input: this.inputTarget
    })
  }

  disconnect() {
    this.markdownEditor.destroy()
    this.markdownEditor = null
  }

  async togglePreview() {
    if (this.previewing) {
      this.element.classList.remove('markdown-editor--previewing')
      this.previewing = false
    } else {
      const response = await post('/preview', {
        body: {
          content: this.inputTarget.value
        }
      })

      if (response.ok) {
        this.previewTarget.innerHTML = await response.text
        this.element.classList.add('markdown-editor--previewing')
        this.previewing = true
      }
    }
  }

  write() {
    this.element.classList.remove('markdown-editor--previewing')
  }

  formatBold() {
    this.markdownEditor.formatBold()
  }

  formatItalic() {
    this.markdownEditor.formatItalic()
  }

  formatTitle() {
    this.markdownEditor.formatTitle()
  }

  formatCode() {
    this.markdownEditor.formatCode()
  }

  formatQuote() {
    this.markdownEditor.formatQuote()
  }

  formatListBulleted() {
    this.markdownEditor.formatListBulleted()
  }

  formatListNumbered() {
    this.markdownEditor.formatListNumbered()
  }

  formatLink() {
    this.markdownEditor.formatLink()
  }

  formatImage() {
    this.markdownEditor.attachFile()
  }
}
