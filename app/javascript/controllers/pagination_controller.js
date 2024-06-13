import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ["nextPageLink"]

  static values = {
    manualLoad: Boolean,
    rootMargin: String
  }

  connect() {
    this.observeNextPageLink()
  }

  observeNextPageLink() {
    if (this.manualLoadValue) {
      return
    }

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

  loadNext(event) {
    event.preventDefault()
    this.loadNextPage()
  }

  async loadNextPage() {
    const response = await get(this.nextPageLinkTarget.href)
    if (response.ok) {
      const html = await response.html
      const dom = new DOMParser().parseFromString(html, 'text/html')
      this.nextPageLinkTarget.outerHTML = dom.getElementById(this.element.id).innerHTML
      this.observeNextPageLink()
    }
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
