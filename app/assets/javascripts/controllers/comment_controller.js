import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    id: Number
  }

  static targets = ["likeButtonForm", "replyList"]

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
    this.element.classList.add("comment--show-replies")
  }

  hideReplies() {
    this.element.classList.remove("comment--show-replies")
    this.replyListTarget.innerHTML = ""
  }
}
