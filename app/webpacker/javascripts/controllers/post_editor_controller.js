import { Controller } from "stimulus"
import { Editor } from "../lib/editor"
import { DirectUpload } from "@rails/activestorage"
import { Turbo } from '@hotwired/turbo-rails'

const isMac = /Mac/.test(navigator.platform)

export default class extends Controller {
  static values = {
    directUploadUrl: String
  }

  static targets = ['form', 'titleInput', 'contentEditor', 'contentInput', 'saveStatus', 'toolbarContainer']

  connect() {
    this.initEditor()

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

    this.formTarget.addEventListener('keydown', () => {
      this.editing()
    })

    this.element.addEventListener('mousemove', () => {
      this.viewing()
    })
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
    this.editor = new Editor(this.contentEditorTarget, {
      input: this.contentInputTarget,
      uploadImage: (file) => {
        return new Promise(function(resolve, reject) {
          const upload = new DirectUpload(file, directUploadUrl)
          upload.create((error, blob) => {
            if (error) {

            } else {
              resolve(`/attachments/${blob.key}/${blob.filename}`)
            }
          })
        })
      },
      toolbar: {
        parent: this.toolbarContainerTarget
      }
    })
  }

  editing() {
    this.element.classList.add('post-editor--editing')
  }

  viewing() {
    this.element.classList.remove('post-editor--editing')
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

  save() {
    if (!this.saving) {
      this.saving = true
      this.clearSaveTimer()
      this.displaySaving()
      this.formTarget.dispatchEvent(new Event('submit', { bubbles: true }))
    }
  }

  submitEnd(event) {
    this.saving = false
    this.displaySaved()
    let response = event.detail.fetchResponse.response
    if (response.ok) {
      const location = response.headers.get('Location')
      if (location) {
        let url = new URL(location)
        Turbo.navigator.history.replace(url)
        this.formTarget.setAttribute('action', url.pathname.slice(0, -5)) // remove '/edit'
        let methodInput = document.createElement('input')
        methodInput.type = 'hidden'
        methodInput.name = '_method'
        methodInput.value = 'PUT'
        this.formTarget.appendChild(methodInput)
      }
    } else {
      // TODO: errror notice and save local
    }

  }
}
