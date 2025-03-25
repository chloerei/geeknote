import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="post-editor"
export default class extends Controller {
  static targets = [ "form", "submitButton", "publishButton", "titleInput", "contentInput", "markdownEditor", "editButton", "previewButton", "toolbarButton" ]

  static values = {
    previewUrl: String
  }

  connect() {
    this.onKeydownHandler = this.onKeydown.bind(this)
    window.addEventListener("keydown", this.onKeydownHandler)
  }

  disconnect() {
    window.removeEventListener("keydown", this.onKeydownHandler)
  }

  onKeydown(event) {
    if ((event.ctrlKey || event.metaKey) && event.key === "s") {
      event.preventDefault()
      this.submit()
    }
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

  preview() {
    this.markdownEditorTarget.preview()
    this.editButtonTarget.classList.remove("button--active")
    this.previewButtonTarget.classList.add("button--active")
    this.toolbarButtonTargets.forEach(button => {
      button.disabled = true
    })
    this.titleInputTarget.disabled = true
  }

  edit() {
    this.markdownEditorTarget.edit()
    this.editButtonTarget.classList.add("button--active")
    this.previewButtonTarget.classList.remove("button--active")
    this.toolbarButtonTargets.forEach(button => {
      button.disabled = false
    })
    this.titleInputTarget.disabled = false
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
