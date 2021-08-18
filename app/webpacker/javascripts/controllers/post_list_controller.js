import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["item"]

  static values = {
    collectionId: String
  }

  connect() {
    if (this.collectionIdValue) {
      this.itemTargets.forEach((item) => {
        let link = item.querySelector('a')
        link.href = item.dataset.url + `?collection_id=${this.collectionIdValue}`
      })
    }
  }
}
