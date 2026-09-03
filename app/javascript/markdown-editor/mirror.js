import { EditorView, ViewPlugin, keymap, placeholder as placeholderPlugin, Decoration } from "@codemirror/view"
import { EditorState, EditorSelection, StateEffect, StateField } from "@codemirror/state"
import { indentOnInput, bracketMatching, syntaxHighlighting, HighlightStyle } from "@codemirror/language"
import { defaultKeymap, history, historyKeymap } from "@codemirror/commands"
import { closeBrackets, closeBracketsKeymap } from "@codemirror/autocomplete"
import { markdown } from "@codemirror/lang-markdown"
import { GFM } from "@lezer/markdown"
import { tags } from "@lezer/highlight"

import { StyleModule } from "style-mod"
StyleModule.mount = () => { /* Disabled it ! */ }

const classHighlightStyle = HighlightStyle.define(
  Object.keys(tags).map((key) => {
    return { tag: tags[key], class: `cmt-${key}` }
  })
)

// Highlight the text replaced by findAndReplace until the document is edited again
const addHighlightEffect = StateEffect.define({
  map: (ranges, mapping) => ranges.map(({ from, to }) => ({
    from: mapping.mapPos(from),
    to: mapping.mapPos(to)
  }))
})

const highlightMark = Decoration.mark({ class: "cm-replaced-highlight" })

const highlightField = StateField.define({
  create: () => Decoration.none,
  update(decorations, transaction) {
    for (const effect of transaction.effects) {
      if (effect.is(addHighlightEffect)) {
        return Decoration.set(
          effect.value.map(({ from, to }) => highlightMark.range(from, to)),
          true
        )
      }
    }

    // Editing the document again (typing, undo, ...) clears the highlight
    if (transaction.docChanged) {
      return Decoration.none
    }

    return decorations
  },
  provide: (field) => EditorView.decorations.from(field)
})

EditorView.EDIT_CONTEXT = false

class MarkdownMirror {
  constructor({ parent, input, scrollMargin, onFileAccept, onFileAttach } = {
    scrollMargin: { top: 0, bottom: 0 }
  }) {
    this.onFileAccept = onFileAccept
    this.onFileAttach = onFileAttach
    this.editorView = new EditorView({
      state: EditorState.create({
        doc: input.value,
        extensions: [
          history(),
          highlightField,
          indentOnInput(),
          syntaxHighlighting(classHighlightStyle, { fallback: true }),
          bracketMatching(),
          closeBrackets(),
          placeholderPlugin(input.placeholder),
          keymap.of([
            ...closeBracketsKeymap,
            ...defaultKeymap,
            ...historyKeymap,
          ]),
          markdown({
            extensions: GFM
          }),
          // sync doc value to inputElement
          ViewPlugin.define((view) => {
            return {
              update: (viewUpdate) => {
                if (input && viewUpdate.docChanged) {
                  input.value = view.state.doc.toString()
                  input.dispatchEvent(new Event("input", { bubbles: true }))
                }
              }
            }
          }),
          EditorView.scrollMargins.of((view) => {
            return scrollMargin
          }),
          EditorView.domEventHandlers({
            focus: (event, view) => {
              parent.dispatchEvent(new Event("focus", { bubbles: true }))
            },
            blur: (event, view) => {
              parent.dispatchEvent(new Event("blur", { bubbles: true }))
            },
            // Uplaod image from clipboard
            paste: (event, view) => {
              if (event.clipboardData.files.length) {
                event.preventDefault()
                Array.from(event.clipboardData.files).forEach((file) => {
                  this.attachFile(file)
                })
              }
            },
            drop: (event, view) => {
              if (event.dataTransfer.files.length) {
                event.preventDefault()
                Array.from(event.dataTransfer.files).forEach((file) => {
                  this.attachFile(file)
                })
              }
            }
          })
        ]
      }),
      parent: parent
    })
  }

  destroy() {
    this.editorView.dom.remove()
    this.editorView = null
  }

  focus() {
    this.editorView.focus()
  }

  getContent() {
    return this.editorView.state.doc.toString()
  }

  setContent(content, { highlight = false } = {}) {
    const current = this.editorView.state.doc.toString()
    if (current === content) return

    const changes = { from: 0, to: current.length, insert: content }
    const effects = []

    if (highlight) {
      const changeSet = this.editorView.state.changes(changes)
      const highlights = []
      // Collect the written range directly in the resulting document. Mapping the
      // old [0, length] boundaries is unreliable when the document was empty
      // (both endpoints collapse onto the same position), which would produce an
      // empty or inverted decoration range.
      changeSet.iterChangedRanges((fromA, toA, fromB, toB) => {
        if (toB > fromB) highlights.push({ from: fromB, to: toB })
      })
      if (highlights.length) effects.push(addHighlightEffect.of(highlights))
    }

    this.editorView.dispatch({ changes, effects })
  }

  insertText(text) {
    const range = this.editorView.state.selection.ranges[0]

    this.editorView.dispatch({
      changes: { from: range.from, to: range.to, insert: text },
      selection: { anchor: range.from + text.length }
    })
  }

  findAndReplace(findText, replaceText, { replaceAll = false, highlight = false } = {}) {
    if (findText === "") return

    const changes = []
    const doc = this.editorView.state.doc.toString()
    let pos = 0

    while (true) {
      const index = doc.indexOf(findText, pos)
      if (index === -1) break
      changes.push({ from: index, to: index + findText.length, insert: replaceText })
      if (!replaceAll) break
      pos = index + findText.length
    }

    if (changes.length) {
      const effects = []

      if (highlight) {
        const changeSet = this.editorView.state.changes(changes)
        const highlights = []
        // Same reasoning as setContent: read the replaced ranges in the resulting
        // document. Ranges that collapse to zero width (pure deletion) are skipped
        // because mark decorations cannot be empty.
        changeSet.iterChangedRanges((fromA, toA, fromB, toB) => {
          if (toB > fromB) highlights.push({ from: fromB, to: toB })
        })
        if (highlights.length) effects.push(addHighlightEffect.of(highlights))
      }

      this.editorView.dispatch({ changes, effects })
    }
  }

  wrapSelection(before, after) {
    this.editorView.dispatch(this.editorView.state.changeByRange(range => ({
      changes: [{ from: range.from, insert: before }, { from: range.to, insert: after}],
      range: EditorSelection.range(range.from + before.length, range.to + before.length)
    })))
    this.editorView.focus()
  }

  linePrepend(mark) {
    this.editorView.dispatch(this.editorView.state.changeByRange(range => {
      let changes = []
      for (let pos = range.from; pos <= range.to;) {
        let line = this.editorView.state.doc.lineAt(pos)
        changes.push({ from: line.from, insert: mark })
        pos = line.to + 1
      }

      let changeSet = this.editorView.state.changes(changes)

      return {
        changes,
        range: EditorSelection.range(changeSet.mapPos(range.anchor, 1), changeSet.mapPos(range.head, 1))
      }
    }))
    this.editorView.focus()
  }

  attachFile(file) {
    if (this.onFileAccept && !this.onFileAccept(file)) {
      alert(`File ${file.name} is not allowed.`)
      return
    }

    const placeholder = `<!-- Uploading ${file.name}... -->`
    this.insertText(placeholder)

    if (this.onFileAttach) {
      this.onFileAttach(file, ({ url, name }) => {
        if (file.type.startsWith("image")) {
          this.findAndReplace(placeholder, `![${name}](${url})`)
        } else {
          this.findAndReplace(placeholder, `[${name}](${url})`)
        }
      })
    }
  }
}

export { MarkdownMirror }
