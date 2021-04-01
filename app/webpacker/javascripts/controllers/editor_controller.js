import { Controller } from "stimulus"
import { Editor } from "../lib/editor"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static values = {
    directUploadUrl: String
  }

  connect() {
    const directUploadUrl = this.directUploadUrlValue
    this.editor = new Editor(this.element, {
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
      }
    })
  }
}
