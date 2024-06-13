import { EditorView, ViewPlugin, keymap, placeholder as placeholderPlugin } from "@codemirror/view"
import { EditorState, EditorSelection } from "@codemirror/state"
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

class MarkdownMirror {
  constructor({ parent, input, scrollMargin } = {
    scrollMargin: { top: 0, bottom: 0 }
  }) {
    this.editorView = new EditorView({
      state: EditorState.create({
        doc: input.value,
        extensions: [
          history(),
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
                  parent.dispatchEvent(new Event("input", { bubbles: true }))
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
                parent.dispatchEvent(new CustomEvent("attach", { detail: { files: event.clipboardData.files }, bubbles: true }))
              }
            },
            drop: (event, view) => {
              if (event.dataTransfer.files.length) {
                event.preventDefault()
                parent.dispatchEvent(new CustomEvent("attach", { detail: { files: event.dataTransfer.files }, bubbles: true }))
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

  insertText(text) {
    const range = this.editorView.state.selection.ranges[0]

    this.editorView.dispatch({
      changes: { from: range.from, to: range.to, insert: text },
      selection: { anchor: range.from + text.length }
    })
  }

  findAndReplace(findText, replaceText) {
    const pos = this.editorView.state.doc.toString().indexOf(findText)
    if (pos > -1) {
      this.editorView.dispatch({
        changes: { from: pos, to: pos + findText.length, insert: replaceText }
      })
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
}

export { MarkdownMirror }
