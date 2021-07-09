import { ViewPlugin, PluginField } from "@codemirror/view"

export function scrollMargin() {
  return ViewPlugin.fromClass(class {
    margin = {
      bottom: 0
    }

    constructor(view) {
    }

    update(update) {
      if (update.docChanged) {
        this.margin = {
          bottom: 100
        }
      } else {
        this.margin = {
          bottom: 0
        }
      }
    }
  }, {
    provide: PluginField.scrollMargins.from(value => value.margin)
  })
}
