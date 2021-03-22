import { Controller } from "stimulus"
import { Editor } from "../lib/editor"

export default class extends Controller {
  connect() {
    this.editor = new Editor(this.element)
  }
}
