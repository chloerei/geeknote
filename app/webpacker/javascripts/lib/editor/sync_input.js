import { ViewPlugin } from "@codemirror/view"

class SyncInputPlugin {
  constructor(view, input) {
    this.view = view
    this.input = input
  }

  update(viewUpdate) {
    if (viewUpdate.docChanged) {
      this.input.value = this.view.state.doc.toString()
      this.input.dispatchEvent(new Event('change'))
    }
  }

  destroy() {
  }
}

export function syncInput(input) {
  if (input) {
    return ViewPlugin.define((view) => new SyncInputPlugin(view, input))
  } else {
    return []
  }
}
