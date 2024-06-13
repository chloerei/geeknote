import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.clean()

    this.element.addEventListener('dragstart', this.dragstart.bind(this))
    this.element.addEventListener('dragend', this.dragend.bind(this))

    this.element.addEventListener('dragover', this.dragover.bind(this))
    this.element.addEventListener('drop', this.drop.bind(this))
  }

  clean() {
    this.draggingItem = null
    this.originIndex = null
    this.dropItem = null
    this.dropPosition = null
  }

  findItem(target) {
    return target.closest('[data-sortable-target="item"]')
  }

  dragstart(event) {
    event.dataTransfer.effectAllowed = "move"
    this.draggingItem = this.findItem(event.target)
    this.originIndex = this.itemTargets.indexOf(this.draggingItem)
  }

  dragend(event) {
    this.clean()
  }

  dragover(event) {
    event.preventDefault()

    if (this.draggingItem) {
      event.dataTransfer.dropEffect = "move"
      let dragoverItem = this.findItem(event.target)

      if (dragoverItem && dragoverItem != this.draggingItem) {

        let rect = dragoverItem.getBoundingClientRect()
        let center = rect.top + rect.height / 2

        if (event.clientY < center) {
          if (this.dropPlaceChanged(dragoverItem, 'before')) {
            dragoverItem.insertAdjacentElement('beforebegin', this.draggingItem)
            this.setDropPlace(dragoverItem, 'before')
          }
        } else {
          if (this.dropPlaceChanged(dragoverItem, 'after')) {
            dragoverItem.insertAdjacentElement('afterend', this.draggingItem)
            this.setDropPlace(dragoverItem, 'after')
          }
        }
      }
    }
  }

  dropPlaceChanged(item, position) {
    return this.dropItem != item || this.dropPosition != position
  }

  setDropPlace(item, position) {
    this.dropItem = item
    this.dropPosition = position
  }

  drop(event) {
    event.preventDefault()
    this.triggerChange()
  }

  triggerChange() {
    if (this.draggingItem) {
      let index = this.itemTargets.indexOf(this.draggingItem)
      if (index != this.originIndex) {
        let event = new CustomEvent('sortable:change', { bubbles: true, detail: { position: index } })
        this.draggingItem.dispatchEvent(event)
      }
    }
  }

  moveToTop(event) {
    this.draggingItem = this.findItem(event.target)
    this.originIndex = this.itemTargets.indexOf(this.draggingItem)
    this.itemTargets[0].insertAdjacentElement('beforebegin', this.draggingItem)
    this.triggerChange()
  }

  moveToBottom(event) {
    this.draggingItem = this.findItem(event.target)
    this.originIndex = this.itemTargets.indexOf(this.draggingItem)
    this.itemTargets[this.itemTargets.length - 1].insertAdjacentElement('afterend', this.draggingItem)
    this.triggerChange()
  }
}
