import { SelectorController } from "@chloerei/material-ui/src/js/material-ui.js"
import { get } from "@rails/request.js"

export default class extends SelectorController {
  disconnect() {
    this.content.remove()
  }

  async onInput() {
    if (this.input.value.length) {
      const response = await get('/tags/search', {
        query: {
          q: this.input.value
        },
        responseKind: "json"
      })

      if (response.ok) {
        const json = await response.json
        this.options = json.tags.map(tag => ({ text: tag.name, value: tag.name }))
        this.renderMenu()
      }
    } else {
      this.options = []
      this.renderMenu()
    }
  }

  renderItem(option) {
    return `
      <div class="selector__item" data-value="${option.value}" data-tag-selector-target="item" data-action="click->tag-selector#select">
        ${ option.create ? `Add ${option.text}...` : option.text }
      </div>
    `
  }

  renderChip(option) {
    return `
      <div class="chip" data-value="${option.value}" data-tag-selector-target="chip">
        ${option.text}
        <div class="chip__action">
          <button type="button" class="button button--icon" data-action="tag-selector#unselect">
            <span class="material-icons">cancel</span>
          </button>
        </div>
      </div>
    `
  }
}
