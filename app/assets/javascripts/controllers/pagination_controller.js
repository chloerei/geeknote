import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {
  static targets = ["nextPageLink"]

  static values = {
    rootMargin: String
  }

  connect() {
    this.observeNextPageLink()
  }

  observeNextPageLink() {
    if (this.hasNextPageLinkTarget) {
      let observer = new IntersectionObserver((entries, observer) => {
        if (entries[0].isIntersecting) {
          observer.disconnect()
          this.loadNextPage()
        }
      }, {
        root: this.scrollableOffsetParent,
        rootMargin: this.rootMarginValue,
      })
      observer.observe(this.nextPageLinkTarget)
    }
  }

  loadNextPage() {
    Rails.ajax({
      url: this.nextPageLinkTarget.href,
      type: 'get',
      success: (data) => {
        let content = data.getElementById(this.element.id)
        this.nextPageLinkTarget.outerHTML = content.innerHTML
        this.observeNextPageLink()
      }
    })
  }

  get scrollableOffsetParent() {
    let offsetParent = this.element.offsetParent
    if (offsetParent.scrollHeight > offsetParent.clientHeight) {
      return offsetParent
    } else {
      return null
    }
  }
}
