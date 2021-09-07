import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["showButton", "showContent", "diffButton", "diffContent"]

  hideChanges() {
    this.element.classList.add('revision--hide-changes')
  }

  showChanges() {
    this.element.classList.remove('revision--hide-changes')
  }
}
