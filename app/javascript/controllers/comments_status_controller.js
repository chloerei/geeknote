import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comments-status"
export default class extends Controller {
  static values = {
    likedIds: Array,
  }

  connect() {
    this.updateLikes()
    this.element.remove()
  }

  updateLikes() {
    console.log(this.likedIdsValue)
    this.likedIdsValue.forEach(id => {
      const element = document.getElementById(`like_comment_${id}`)
      if (element) {
        element.classList.add("liked")
      }
    })
  }
}
