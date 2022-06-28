import { get } from "@rails/request.js"
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async update(event) {
    event.preventDefault()

    const value = event.detail.value

    if (value.length) {
      const response = await get('/tags/search', {
        query: {
          q: value
        },
        responseKind: "json"
      })

      if (response.ok) {
        const json = await response.json
        this.element.selector.options = json.tags.map(tag => ({ text: tag.name, value: tag.name }))
        this.element.selector.renderMenu()
      }
    } else {
      this.element.selector.options = []
      this.element.selector.renderMenu()
    }

  }
}
