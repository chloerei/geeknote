import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["postLink"]

  static values = {
    collectionId: String
  }

  connect() {
    if (this.collectionIdValue) {
      this.postLinkTargets.forEach((link) => {
        let url = new URL(link.href)
        link.href = url.pathname + `?collection_id=${this.collectionIdValue}`
      })
    }
  }
}
