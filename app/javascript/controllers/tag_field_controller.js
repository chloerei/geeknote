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
}
