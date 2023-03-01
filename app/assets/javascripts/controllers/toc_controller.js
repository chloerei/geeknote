import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
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
          item.scrollIntoView({ block: "nearest" })
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
    this.observer = null
  }

  // update() {
  //   if (this.updateTimer) {
  //     return
  //   }

  //   this.updateTimer = setTimeout(() => {
  //     this.itemTargets.forEach(item => {
  //       item.classList.remove("toc__item--active");
  //     })

  //     this.itemTargets.forEach(item => {
  //       console.log(item.dataset)
  //       let target = document.getElementById(item.dataset.id)
  //       console.log(target.getBoundingClientRect())
  //     })

  //     this.updateTimer = null
  //   }, 1000);
  // }
}
