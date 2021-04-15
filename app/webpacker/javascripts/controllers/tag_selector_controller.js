import { SelectorController } from "campo-ui/src/js/campo-ui"
import Rails from "@rails/ujs"

export default class extends SelectorController {
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
            <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24"><path d="M0 0h24v24H0V0z" fill="none" opacity=".87"/><path d="M12 2C6.47 2 2 6.47 2 12s4.47 10 10 10 10-4.47 10-10S17.53 2 12 2zm4.3 14.3c-.39.39-1.02.39-1.41 0L12 13.41 9.11 16.3c-.39.39-1.02.39-1.41 0-.39-.39-.39-1.02 0-1.41L10.59 12 7.7 9.11c-.39-.39-.39-1.02 0-1.41.39-.39 1.02-.39 1.41 0L12 10.59l2.89-2.89c.39-.39 1.02-.39 1.41 0 .39.39.39 1.02 0 1.41L13.41 12l2.89 2.89c.38.38.38 1.02 0 1.41z"/></svg>
          </button>
        </div>
      </div>
    `
  }

  removeSelected(value) {
    super.removeSelected(value)
    // TODO: fix in upstream
    this.selectTarget.dispatchEvent(new Event('change', { bubbles: true }))
  }
}
