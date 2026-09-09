import { EditorView, Decoration, WidgetType } from "@codemirror/view"
import { StateEffect, StateField } from "@codemirror/state"

// Pending AI suggestion decorations (del / ins marks). The full set is
// replaced atomically through suggestionDecoEffect whenever blocks arrive,
// are accepted/rejected, or get re-located after a doc change.
const suggestionDecoEffect = StateEffect.define()

const suggestionDecoField = StateField.define({
  create: () => Decoration.none,
  update(decorations, transaction) {
    for (const effect of transaction.effects) {
      if (effect.is(suggestionDecoEffect)) {
        return effect.value
      }
    }
    return decorations
  },
  provide: (field) => EditorView.decorations.from(field)
})

// Accept / reject pill. Each block gets one, floating above the start of the
// change. It is built as a plain DOM pill and wrapped by AiChipWidget.
function makeChipEl(layer, id) {
  const chip = document.createElement("span")
  chip.className = "cm-ai-chip"

  const accept = document.createElement("button")
  accept.type = "button"
  accept.className = "cm-ai-accept"
  accept.textContent = "✓"
  accept.title = "Accept this suggestion"
  accept.addEventListener("click", () => layer.acceptSuggestion(id))

  const reject = document.createElement("button")
  reject.type = "button"
  reject.className = "cm-ai-reject"
  reject.textContent = "✕"
  reject.title = "Reject this suggestion"
  reject.addEventListener("click", () => layer.rejectSuggestion(id))

  chip.append(accept, reject)
  return chip
}

// Zero-size inline anchor placed at the block start. Its absolutely positioned
// chip floats above the anchor without participating in the line layout, and
// because the anchor is real document content it scrolls with the text for free.
class AiChipWidget extends WidgetType {
  constructor(layer, id) {
    super()
    this.layer = layer
    this.id = id
  }

  eq(other) {
    return other instanceof AiChipWidget && other.id === this.id
  }

  ignoreEvent() {
    return true
  }

  toDOM() {
    const anchor = document.createElement("span")
    anchor.className = "cm-ai-chip-anchor"
    anchor.append(makeChipEl(this.layer, this.id))
    return anchor
  }
}

// The proposed replacement text, shown in green right after the deleted span.
class AiInsertWidget extends WidgetType {
  constructor(text) {
    super()
    this.text = text
  }

  eq(other) {
    return other instanceof AiInsertWidget && other.text === this.text
  }

  ignoreEvent() {
    return true
  }

  toDOM() {
    const dom = document.createElement("span")
    dom.className = "cm-ai-ins"
    dom.textContent = this.text
    return dom
  }
}

// Renders AI content suggestions inside a CodeMirror editor and lets the user
// accept or reject each one. Blocks arrive from the write tools as anchored
// text changes; accepting applies them to the document, rejecting drops them.
// The document is never modified without user action.
class AiSuggestionLayer {
  constructor(view, { onChange } = {}) {
    this.view = view
    this.onChange = onChange
    this.contentSuggestions = []
    this.timer = null
  }

  destroy() {
    clearTimeout(this.timer)
    this.timer = null
    this.contentSuggestions = []
    this.view = null
  }

  // A suggestion block is one of:
  //   { id, type: "replace", oldText, newText }  -> anchored text replacement
  //   { id, type: "rewrite", newText }           -> whole document replacement
  appendSuggestionBlock(block) {
    if (!this.view) return

    // A rewrite supersedes any pending localized edits (conflicting semantics).
    if (block.type === "rewrite") {
      this.contentSuggestions = []
    }
    this.contentSuggestions.push(block)
    this.relocateSuggestions()
  }

  get pendingContentCount() {
    return this.contentSuggestions.length
  }

  get hasRewritePending() {
    return this.contentSuggestions.some((block) => block.type === "rewrite")
  }

  acceptSuggestion(id) {
    if (!this.view) return

    const index = this.contentSuggestions.findIndex((block) => block.id === id)
    if (index === -1) return

    const [block] = this.contentSuggestions.splice(index, 1)
    const doc = this.view.state.doc.toString()

    if (block.type === "rewrite") {
      if (doc !== block.newText) {
        this.applyChange(0, doc.length, block.newText)
      }
    } else {
      // Locate again at accept time so user edits between render and click
      // never replace the wrong span. Not uniquely found => silently dropped.
      const from = this.findUniqueIndex(block.oldText, doc)
      if (from !== null) {
        this.applyChange(from, from + block.oldText.length, block.newText)
      }
    }

    this.refreshDecorations()
    this.notifyChange()
  }

  rejectSuggestion(id) {
    if (!this.view) return

    const index = this.contentSuggestions.findIndex((block) => block.id === id)
    if (index === -1) return

    this.contentSuggestions.splice(index, 1)
    this.refreshDecorations()
    this.notifyChange()
  }

  acceptAllSuggestions() {
    if (!this.view || this.contentSuggestions.length === 0) return

    const pending = this.contentSuggestions.slice()
    this.contentSuggestions = []
    const doc = this.view.state.doc.toString()

    if (pending.some((block) => block.type === "rewrite")) {
      const rewrite = pending.find((block) => block.type === "rewrite")
      if (doc !== rewrite.newText) {
        this.applyChange(0, doc.length, rewrite.newText)
      }
    } else {
      // Apply in arrival order; each block is re-located against the evolving doc.
      for (const block of pending) {
        const current = this.view.state.doc.toString()
        const from = this.findUniqueIndex(block.oldText, current)
        if (from !== null) {
          this.applyChange(from, from + block.oldText.length, block.newText)
        }
      }
    }

    this.refreshDecorations()
    this.notifyChange()
  }

  rejectAllSuggestions() {
    if (!this.view) return

    this.contentSuggestions = []
    this.refreshDecorations()
    this.notifyChange()
  }

  // Re-locate pending blocks after a document change (debounced), dropping the
  // ones whose old_text is no longer present or unique.
  handleDocChange() {
    if (!this.view || this.contentSuggestions.length === 0) return

    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      this.timer = null
      this.relocateSuggestions()
    }, 300)
  }

  notifyChange() {
    this.onChange?.(this.contentSuggestions)
  }

  applyChange(from, to, insert) {
    this.view.dispatch({ changes: { from: from, to: to, insert: insert } })
  }

  // Returns the start index when needle occurs exactly once, null otherwise.
  findUniqueIndex(needle, doc) {
    if (!needle) return null

    const first = doc.indexOf(needle)
    if (first === -1) return null

    let index = first + needle.length
    while ((index = doc.indexOf(needle, index)) !== -1) {
      return null
    }
    return first
  }

  // Re-locate every pending replace block against the current doc. Blocks whose
  // old_text is no longer unique or present are dropped (the suggestion no
  // longer applies; keep the user's text). Called on arrival and after edits.
  relocateSuggestions() {
    if (!this.view) return

    const doc = this.view.state.doc.toString()
    const kept = []

    for (const block of this.contentSuggestions) {
      if (block.type === "rewrite") {
        kept.push(block)
        continue
      }

      const from = this.findUniqueIndex(block.oldText, doc)
      if (from === null) continue

      block.from = from
      block.to = from + block.oldText.length
      kept.push(block)
    }

    const changed = kept.length !== this.contentSuggestions.length
    this.contentSuggestions = kept
    this.refreshDecorations()
    if (changed) this.notifyChange()
  }

  refreshDecorations() {
    if (!this.view) return

    const decorations = []
    const doc = this.view.state.doc.toString()

    for (const block of this.contentSuggestions) {
      if (block.type === "rewrite") {
        const chip = new AiChipWidget(this, block.id)
        decorations.push(Decoration.widget({ widget: chip }).range(0))
        if (doc.length > 0) {
          decorations.push(Decoration.mark({ class: "cm-ai-del" }).range(0, doc.length))
        }
        this.pushInsertion(decorations, block.newText, doc.length, { block: true })
      } else if (block.from !== undefined) {
        const chip = new AiChipWidget(this, block.id)
        decorations.push(Decoration.widget({ widget: chip }).range(block.from))
        if (block.to > block.from) {
          decorations.push(Decoration.mark({ class: "cm-ai-del" }).range(block.from, block.to))
        }
        this.pushInsertion(decorations, block.newText, block.to)
      }
    }

    this.view.dispatch({
      effects: suggestionDecoEffect.of(Decoration.set(decorations, true))
    })
  }

  // The replacement text is shown inline right after the deleted span so a
  // localized suggestion stays in the text flow. CodeMirror inline widgets
  // cannot contain line breaks (the content would be clipped or misaligned),
  // so multi-line replacements fall back to a block widget on its own lines.
  // A whole-document rewrite always renders as a block at the end of the doc.
  pushInsertion(decorations, text, position, { block = false } = {}) {
    if (!text) return

    const widget = new AiInsertWidget(text)
    const options = block || text.includes("\n") ? { widget: widget, block: true } : { widget: widget }
    decorations.push(Decoration.widget(options).range(position))
  }
}

export { suggestionDecoField, AiSuggestionLayer }
