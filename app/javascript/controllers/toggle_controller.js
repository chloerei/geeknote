import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static outlets = [ "dialog" ]

  connect() {
  }

  dialog() {
    if (this.hasDialogOutlet) {
      this.dialogOutlet.open()
    }
  }
}
