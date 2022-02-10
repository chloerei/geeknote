import { SelectorController } from "@chloerei/material-ui/dist/material-ui.js"
import Rails from "@rails/ujs"

export default class extends SelectorController {
  disconnect() {
    this.content.remove()
  }

  onInput() {
    if (this.input.value.length) {
      Rails.ajax({
        url: '/tags/search?q=' + this.input.value,
        type: 'get',
        content_type: 'json',
        success: (data) => {
          this.options = data.tags.map(tag => ({ text: tag.name, value: tag.name }))
          this.renderMenu()
        }
      })
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
