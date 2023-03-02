import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.scrollParent = this.getScrollParent(this.element)

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        let item = this.itemTargets.find((item) => item.dataset.id == entry.target.id)
        if (entry.isIntersecting && entry.intersectionRatio == 1) {
          item.classList.add("toc__item--visible")
        } else {
          item.classList.remove("toc__item--visible")
        }
      })

      let firstItem = this.itemTargets.find((item) => item.classList.contains("toc__item--visible"))

      if (firstItem) {
        this.currentItem = firstItem
      }

      this.itemTargets.forEach((item) => {
        if (item == this.currentItem) {
          item.classList.add("toc__item--active")

          if (this.scrollParent) {
            let parentRect = this.scrollParent.getBoundingClientRect()
            let itemRect = item.getBoundingClientRect()
            let scrollOffsetTop = itemRect.top - parentRect.top + this.scrollParent.scrollTop
            if (this.scrollParent.scrollTop + parentRect.height < scrollOffsetTop + itemRect.height) {
              // scroll item to bottom
              this.scrollParent.scrollTo(0, scrollOffsetTop + itemRect.height - parentRect.height)
            } else if (this.scrollParent.scrollTop > scrollOffsetTop) {
              // scroll item to top
              this.scrollParent.scrollTo(0, scrollOffsetTop)
            }

          }
        } else {
          item.classList.remove("toc__item--active")
        }
      })
    }, {
      threshold: 1
    })

    this.itemTargets.forEach(item => {
      let target = document.getElementById(item.dataset.id)

      if (target) {
        this.observer.observe(target)
      }
    })
  }

  disconnect() {
    this.observer.disconnect()
  }

  getScrollParent(element) {
    if (element == null) {
      return null
    } else if (element.scrollHeight > element.clientHeight) {
      return element
    } else {
      return this.getScrollParent(element.parentNode)
    }
  }
}
