import { ViewPlugin, PluginField } from "@codemirror/view"

export function scrollMargin() {
  return ViewPlugin.fromClass(class {
    margin = {
      bottom: 120
    }

    constructor(view) {
    }

  }, {
    provide: PluginField.scrollMargins.from(value => value.margin)
  })
}
