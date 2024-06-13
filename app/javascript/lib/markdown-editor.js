import { DirectUpload } from "@rails/activestorage"
import { post } from '@rails/request.js'
import { MarkdownMirror } from "markdown-mirror"

class MarkdownEditor {
  static acceptFileTypes = [
    'image/png',
    'image/gif',
    'image/jpeg',
  ]

  static acceptFileSize = 10 * 1024 * 1024

  static uploadFile(file) {
    return new Promise((resolve, reject) => {
      const upload = new DirectUpload(file, "/rails/active_storage/direct_uploads")
      upload.create(async (error, blob) => {
        if (error) {
          reject(error)
        } else {
          let formData = new FormData()
          formData.append('attachment[file]', blob.signed_id)
          const response = await post('/attachments', {
              body: formData
            }
          )
          if (response.ok) {
            const data = await response.json
            resolve(data)
          }
        }
      })
    })
  }

  constructor({ parent, input, scrollMargin }) {
    this.parent = parent

    scrollMargin = scrollMargin || { top: 0, bottom: 0 }

    this.markdownMirror = new MarkdownMirror({
      parent: parent,
      input: input,
      scrollMargin: scrollMargin,
    })
    this.editorView = this.markdownMirror.editorView

    this.mirrorAttachFile = (event) => {
      Array.from(event.detail.files).forEach(file => {
        this.uploadAndInsertFile(file)
      })
    }
    this.parent.addEventListener('attach', this.mirrorAttachFile)
  }

  destroy() {
    this.parent.removeEventListener('attach', this.mirrorAttachFile)
    this.markdownMirror.destroy()
  }

  focus() {
    this.markdownMirror.focus()
  }

  attachFile() {
    const input = document.createElement('input')
    input.type = 'file'
    input.multiple = true
    input.accept = MarkdownEditor.acceptFileTypes.join(',')

    input.onchange = (event) => {
      Array.from(event.target.files).forEach(file => {
        this.uploadAndInsertFile(file)
      })
    }

    input.click()
  }

  async uploadAndInsertFile(file) {
    if (file.size > MarkdownEditor.acceptFileSize) {
      alert(`File size is too large. Maximum file size is ${MarkdownEditor.acceptFileSize / 1024 / 1024}MB.`)
      return
    }

    if (!MarkdownEditor.acceptFileTypes.includes(file.type)) {
      alert("File type is not allowed.")
      return
    }

    const placeholder = `<!-- Uploading ${file.name}... -->`

    this.markdownMirror.insertText(placeholder)
    this.markdownMirror.focus()

    const { url, filename, content_type } = await MarkdownEditor.uploadFile(file)

    let markup = ""

    if (content_type.startsWith("image")) {
      markup = `![${filename}](${url})`
    } else {
      markup = `[${filename}](${url})`
    }

    this.markdownMirror.findAndReplace(placeholder, markup)
  }

  formatBold() {
    this.markdownMirror.wrapSelection('*', '*')
  }

  formatItalic() {
    this.markdownMirror.wrapSelection('_', '_')
  }

  formatTitle() {
    this.markdownMirror.linePrepend('## ')
  }

  formatCode() {
    this.markdownMirror.wrapSelection('`', '`')
  }

  formatQuote() {
    this.markdownMirror.linePrepend('> ')
  }

  formatListBulleted() {
    this.markdownMirror.linePrepend('- ')
  }

  formatListNumbered() {
    this.markdownMirror.linePrepend('1. ')
  }

  formatLink() {
    this.markdownMirror.wrapSelection('[', ']()')
  }
}

export { MarkdownEditor }
