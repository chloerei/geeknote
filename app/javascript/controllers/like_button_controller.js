import { Controller } from "@hotwired/stimulus"
import { Current } from "lib/current"

// Connects to data-controller="like-button"
export default class extends Controller {
  static values = {
    likedUserIds: Array
  }

  connect() {
    this.update()
  }

  update() {
    if (this.likedUserIdsValue.includes(Current.user.id)) {
      this.element.classList.add('liked')
    } else {
      this.element.classList.remove('liked')
    }
  }
}
