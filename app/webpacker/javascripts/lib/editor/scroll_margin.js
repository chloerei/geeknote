import { ViewPlugin, PluginField } from "@codemirror/view"

export function scrollMargin() {
  return ViewPlugin.fromClass(class {
    constructor() {
      this.margin = {
        bottom: 160
      }
    }
  }, {
    provide: PluginField.scrollMargins.from(value => value.margin)
  })
}
