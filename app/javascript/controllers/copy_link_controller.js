import { Controller } from "@hotwired/stimulus"
import SnackbarController from "controllers/snackbar_controller"

// Connects to data-controller="copy-link"
export default class extends Controller {
  static values = {
    url: String
  }

  copy() {
    const url = new URL(this.urlValue, window.location.origin)
    navigator.clipboard.writeText(url)
    this.element.blur()
    SnackbarController.show("Link copied to clipboard")
  }
}
