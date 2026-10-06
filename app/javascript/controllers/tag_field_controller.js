import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"
import { get } from "@rails/request.js"

// Connects to data-controller="tag-field"
export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.tomSelect = new TomSelect(this.inputTarget, {
      plugins: ["remove_button"],
      create: true,
      persist: false,
      valueField: "name",
      labelField: "name",
      searchField: "name",
      load: async (query, callback) => {
        const url = "/suggest/tags?query=" + encodeURIComponent(query)
        const response = await get(url, {
          responseKind: "json"
        })
        if (response.ok) {
          const data = await response.json
          callback(data)
        } else {
          callback()
        }
      },
      loadingClass: "ts-loading", // conflict with daisyUI's loading class
      render: {
        loading: () => {
          return `
            <div class="p-2 text-base-content/80">
              <div class="loading loading-spinner"></div>
            </div>
          `
        }
      },
      onItemAdd: () => {
        this.tomSelect.setTextboxValue("")
        this.tomSelect.refreshOptions()
      },
    })
  }

  disconnect() {
    this.tomSelect.destroy()
  }

  // Adds tag names programmatically (e.g. AI suggestions). addItem ignores a
  // value that has no option yet, so missing options are created first. Tags
  // already selected are skipped, compared case insensitively because tag names
  // are case insensitive on the server. The tags already there are kept and the
  // new ones fill the remaining room up to +limit+. The input event keeps the
  // editor's unsaved-changes checker in sync.
  addTags(names, limit = Infinity) {
    if (!this.tomSelect) return

    const selected = this.tomSelect.items.map((item) => item.toLowerCase())
    let added = false

    for (const name of names) {
      if (selected.length >= limit) break

      const value = name?.trim()
      if (!value || selected.includes(value.toLowerCase())) continue

      selected.push(value.toLowerCase())
      if (!this.tomSelect.options[value]) {
        this.tomSelect.addOption({ name: value })
      }
      this.tomSelect.addItem(value)
      added = true
    }

    // Nothing changed, nothing to mark as unsaved.
    if (added) {
      this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
    }
  }
}
