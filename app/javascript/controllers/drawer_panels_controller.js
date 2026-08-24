import { Controller } from "@hotwired/stimulus"

// Manages a drawer that shows one of several panels. Buttons and panels are
// matched by their data-panel value. The active panel is persisted on the
// toggle element; mark it with data-turbo-permanent to survive Turbo morphing
// and page renders.
export default class extends Controller {
  static targets = ["toggle", "panel", "button"]

  connect() {
    this.sync(this.activePanel())
  }

  afterMorph() {
    this.sync(this.activePanel())
  }

  toggle(event) {
    const panel = event.currentTarget.dataset.panel

    if (this.toggleTarget.checked && this.activePanel() === panel) {
      this.sync(null)
    } else {
      this.sync(panel)
    }
  }

  toggleChanged() {
    // The drawer can be closed via overlay or close labels, which bypass
    // toggle(). Keep the persisted state in sync with the checkbox.
    if (!this.toggleTarget.checked) {
      this.sync(null)
    }
  }

  activePanel() {
    return this.toggleTarget.dataset.activePanel || null
  }

  sync(panel) {
    this.toggleTarget.checked = !!panel
    this.toggleTarget.dataset.activePanel = panel ?? ""

    for (const element of this.panelTargets) {
      element.classList.toggle("hidden", element.dataset.panel !== panel)
    }
    for (const element of this.buttonTargets) {
      element.classList.toggle("btn-active", element.dataset.panel === panel)
    }
  }
}
