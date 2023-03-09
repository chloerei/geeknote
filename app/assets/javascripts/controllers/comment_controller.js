import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    id: Number
  }

  static targets = ["likeButton", "replies"]

  likeButtonTargetConnected(element) {
    const currentUserId = parseInt(document.querySelector("meta[name='current-user-id']")?.getAttribute('content'))
    const likedUserIds = JSON.parse(element.dataset.likedUserIds || '[]')
    if (currentUserId && likedUserIds.includes(currentUserId)) {
      element.setAttribute('data-turbo-method', 'delete')
      element.classList.add('button--active')
    }
  }

  showReplies() {
    this.element.classList.add("comment--show-replies")
  }

  hideReplies() {
    this.element.classList.remove("comment--show-replies")
    this.repliesTarget.innerHTML = ""
  }
}
