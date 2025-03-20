import { Controller } from "@hotwired/stimulus"
import { post } from '@rails/request.js'

// Connects to data-controller="post-editor"
export default class extends Controller {
  static targets = [ "form", "submitButton", "publishButton", "container", "titleInput", "contentInput", "markdownEditor", "preview", "toolbarButton" ]

  static values = {
    previewUrl: String
  }

  connect() {
  }

  disconnect() {
  }

  titleInputTargetConnected() {
    this.resizeTitleInput()
  }

  resizeTitleInput() {
    this.titleInputTarget.style.height = 0
    this.titleInputTarget.style.height = (this.titleInputTarget.scrollHeight) + 'px'
  }

  focus() {
    this.markdownEditorTarget.focus()
  }

  submit() {
    this.formTarget.dispatchEvent(new CustomEvent('submit', { bubbles: true, cancelable: true }))
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

  async preview() {
    this.previewTarget.innerHTML = ''
    this.containerTarget.classList.add('previewing')
    window.scrollTo(0, 0)
    this.toolbarButtonTargets.forEach(button => {
      button.disabled = true
    })

    const formData = new FormData(this.formTarget)
    formData.delete('_method')

    const response = await post(this.previewUrlValue, {
        body: formData
      }
    )

    if (response.ok) {
      const html = await response.html

      this.previewTarget.innerHTML = html
    }
  }

  write() {
    this.containerTarget.classList.remove('previewing')
    window.scrollTo(0, 0)
    this.toolbarButtonTargets.forEach(button => {
      button.disabled = false
    })
  }

  handleChanges() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = false
    }
    if (this.hasPublishButtonTarget) {
      this.publishButtonTarget.disabled = true
    }
  }
}
