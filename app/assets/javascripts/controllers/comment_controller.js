import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    id: Number,
    likedUserIds: Array
  }

  static targets = ["likeButton", "replyList"]

  connect() {
    this.modifyLikeButton()
  }

  modifyLikeButton() {
    const currentUserId = parseInt(document.querySelector("meta[name='current-user-id']")?.getAttribute('content'))
    if (currentUserId && this.likedUserIdsValue.includes(currentUserId)) {
      this.likeButtonTarget.setAttribute('data-turbo-method', 'delete')
      this.likeButtonTarget.classList.add('button--active')
    }
  }

  showReplies() {
    this.element.classList.add("comment--show-replies")
  }

  hideReplies() {
    this.element.classList.remove("comment--show-replies")
    this.replyListTarget.innerHTML = ""
  }
}
