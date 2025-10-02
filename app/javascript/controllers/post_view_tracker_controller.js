import { Controller } from "@hotwired/stimulus"
import ahoy from "ahoy.js"

// Connects to data-controller="post-view-tracker"
export default class extends Controller {
  static values = {
    postId: Number
  }

  connect() {
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          ahoy.track("Viewed post", { post_id: this.postIdValue })
          this.observer.disconnect()
        }
      })
    })
    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }
}
