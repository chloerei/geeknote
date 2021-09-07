import { Controller } from "stimulus"
import { Editor } from "../lib/editor"
import { DirectUpload } from "@rails/activestorage"
import { Turbo } from '@hotwired/turbo-rails'
import { Snackbar } from '../lib/snackbar'
import Rails from "@rails/ujs"

const isMac = /Mac/.test(navigator.platform)

export default class extends Controller {
  static values = {
    directUploadUrl: String,
    attachmentsUrl: String,
    messageImageLimit: String,
    readonly: Boolean
  }

  static targets = ['form', 'titleInput', 'contentEditor', 'contentInput', 'saveStatus']

  connect() {
    this.initEditor()

    if (!this.readonlyValue) {
      this.resizeTitle()
      this.titleInputTarget.addEventListener('keydown', (event) => {
        // Enter
        if (event.keyCode == 13) {
          event.preventDefault()
          this.editor.focus()
        }
      })
      this.titleInputTarget.addEventListener('input', this.resizeTitle.bind(this))

      this.formTarget.addEventListener('turbo:submit-end', this.submitEnd.bind(this))

      this.onKeydownHandler = this.onKeydown.bind(this)
      document.addEventListener('keydown', this.onKeydownHandler)

      this.formTarget.addEventListener('input', () => {
        this.autoSave()
      })

      this.element.addEventListener('dragover', (event) => {
        event.preventDefault()
        event.dataTransfer.dropEffect = "move"
      })

      this.element.addEventListener('drop', (event) => {
        if (event.dataTransfer.files.length) {
          event.preventDefault()
          this.editor.uploadImages(event.dataTransfer.files)
        }
      })
    }
  }

  focusEnd() {
    this.editor.focusEnd()
  }

  resizeTitle() {
    this.titleInputTarget.style.height = 0
    this.titleInputTarget.style.height = this.titleInputTarget.scrollHeight + 'px'
  }

  disconnect() {
    document.removeEventListener('keydown', this.onKeydownHandler)
  }

  initEditor() {
    const directUploadUrl = this.directUploadUrlValue
    const attachmentsUrl = this.attachmentsUrlValue
    this.editor = new Editor(this.contentEditorTarget, {
      input: this.contentInputTarget,
      placeholder: this.contentEditorTarget.dataset.placeholder,
      uploadImage: (file) => {
        return new Promise(function(resolve, reject) {
          const upload = new DirectUpload(file, directUploadUrl)
          upload.create((error, blob) => {
            // Todo: error handle
            let formData = new FormData()
            formData.append('attachment[file]', blob.signed_id)
            Rails.ajax({
              url: attachmentsUrl,
              data: formData,
              type: 'post',
              success: (data) => {
                resolve(data.url)
              }
            })
          })
        })
      },
      messages: {
        imageLimit: this.messageImageLimitValue
      },
      readonly: this.readonlyValue
    })
  }

  selectImage() {
    let input = document.createElement('input')
    input.type = 'file'
    input.multiple = true
    input.accept = 'image/*'

    input.onchange = (event) => {
      this.editor.uploadImages(event.target.files)
    }

    input.click()
  }

  autoSave() {
    if (!this.displayEditingTimer) {
      this.displayEditingTimer = setTimeout(() => {
        if (!this.saving) {
          this.displayEditing()
        }
        this.displayEditingTimer = null
      }, 1000)
    }

    // when typing stop, save content
    if (this.saveLater) {
      clearTimeout(this.saveLater)
    }

    this.saveLater = setTimeout(() => {
      this.save()
    }, 2000)

    // save at least once every minute
    if (!this.saveScheduled) {
      this.saveScheduled = setTimeout(() => {
        this.save()
      }, 60000)
    }
  }

  clearSaveTimer() {
    clearTimeout(this.saveLater)
    this.saveLater = null
    clearTimeout(this.saveScheduled)
    this.saveScheduled = null
  }

  onKeydown(event) {
    if (isMac) {
      if (event.key == 's' && event.metaKey) {
        event.preventDefault()
        this.save()
      }
    } else {
      if (event.key == 's' && event.ctrlKey) {
        event.preventDefault()
        this.save()
      }
    }
  }

  displayEditing() {
    this.saveStatusTarget.textContent = ''
  }

  displaySaving() {
    this.saveStatusTarget.textContent = this.saveStatusTarget.dataset.messageSaving
  }

  displaySaved() {
    this.saveStatusTarget.textContent = this.saveStatusTarget.dataset.messageSaved
  }

  displaySaveFailed() {
    this.saveStatusTarget.textContent = this.saveStatusTarget.dataset.messageSaveFailed
  }

  save() {
    if (!this.saving) {
      this.saving = true
      this.clearSaveTimer()
      this.displaySaving()
      Turbo.navigator.submitForm(this.formTarget)
    }
  }

  submitEnd(event) {
    this.saving = false
    let response = event.detail.fetchResponse.response
    if (response.ok) {
      this.displaySaved()
      const location = response.headers.get('Location')
      if (location) {
        let url = new URL(location)
        Turbo.navigator.history.replace(url)
        let resourcePath = url.pathname.slice(0, -5) // remove '/edit'
        this.formTarget.setAttribute('action', resourcePath)
        let methodInput = document.createElement('input')
        methodInput.type = 'hidden'
        methodInput.name = '_method'
        methodInput.value = 'PUT'
        this.formTarget.appendChild(methodInput)
        document.querySelector('#settings').setAttribute('src', resourcePath + '/settings')
      }
    } else {
      // TODO: save local
      this.displaySaveFailed()
      Snackbar.display('Save failed! Please check your network and refresh.', 30000)
    }
  }
}
