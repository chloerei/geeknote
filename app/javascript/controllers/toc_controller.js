import { Controller } from "@hotwired/stimulus"
import { throttle } from "../lib/utils"

// Connects to data-controller="toc"
export default class extends Controller {
  static targets = ["item"]

  static classes = ["active"]

  static values = {
    contentId: String,
  }

  connect() {
    this.contentElement = document.getElementById(this.contentIdValue)
    if (!this.contentElement) {
      console.error(`Content element with ID "${this.contentIdValue}" not found.`)
      return
    }
    this.headings = Array.from(this.contentElement.querySelectorAll("h2, h3"))
    // Throttle the scroll handler
    this.onScrollHandler = throttle(this.onScroll.bind(this), 250)
    window.addEventListener("scroll", this.onScrollHandler)
    // Initial check on connect
    this.onScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScrollHandler)
  }

  onScroll() {
    let firstVisibleHeading = null
    const viewportTop = 0 // Or use a specific offset if needed, e.g., header height
    const viewportBottom = window.innerHeight

    for (const heading of this.headings) {
      const rect = heading.getBoundingClientRect()
      // Check if the top of the heading is within the viewport (or slightly above)
      if (rect.top >= viewportTop && rect.top <= viewportBottom) {
        firstVisibleHeading = heading
        break // Found the first visible heading
      } else if (rect.top < viewportTop) {
        // when content is long, use the heading just above the viewport
        firstVisibleHeading = heading
      } else if (rect.top > viewportBottom) {
        break
      }
    }

    // Remove active class from all items first
    this.itemTargets.forEach(item => {
      item.classList.remove(this.activeClass)
    })

    if (firstVisibleHeading) {
      const id = firstVisibleHeading.getAttribute("id")
      if (id) {
        const activeItem = this.itemTargets.find(item => item.getAttribute("href") === `#${id}`)
        if (activeItem) {
          activeItem.classList.add(this.activeClass)
          activeItem.scrollIntoView({ block: "nearest" })
        }
      }
    }
  }
}
