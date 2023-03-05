import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    id: Number
  }

  static targets = ["likeButtonForm", "replyList", "showRepliesButton", "hideRepliesButton"]

  connect() {
    this.modifyLikeButton()
  }

  modifyLikeButton() {
    const parent = this.element.parentElement
    if (parent.dataset.likedIds && JSON.parse(parent.dataset.likedIds).includes(this.idValue)) {
      this.likeButtonFormTarget.setAttribute('method', 'delete')
      this.likeButtonFormTarget.querySelector('button').classList.add('button--active')
    }
  }

  showReplies() {
    this.showRepliesButtonTarget.classList.add("display-none")
    this.hideRepliesButtonTarget.classList.remove("display-none")
  }

  hideReplies() {
    this.hideRepliesButtonTarget.classList.add("display-none")
    this.showRepliesButtonTarget.classList.remove("display-none")
    this.replyListTarget.innerHTML = ""
  }
}
