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

import { suggestionDecoField, AiSuggestionLayer } from "./suggestions"

const classHighlightStyle = HighlightStyle.define(
  Object.keys(tags).map((key) => {
    return { tag: tags[key], class: `cmt-${key}` }
  })
)

EditorView.EDIT_CONTEXT = false

class MarkdownMirror {
  constructor({ parent, input, scrollMargin, onFileAccept, onFileAttach, onSuggestionsChange } = {
    scrollMargin: { top: 0, bottom: 0 }
  }) {
    this.onFileAccept = onFileAccept
    this.onFileAttach = onFileAttach
    this.onSuggestionsChange = onSuggestionsChange
    this.editorView = new EditorView({
      state: EditorState.create({
        doc: input.value,
        extensions: [
          history(),
          suggestionDecoField,
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
          // Pending suggestions are anchored by their old_text: re-locate them
          // after any doc change (debounced) so stale blocks disappear by themselves.
          EditorView.updateListener.of((viewUpdate) => {
            if (viewUpdate.docChanged) {
              this.aiSuggestions?.handleDocChange()
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

    this.aiSuggestions = new AiSuggestionLayer(this.editorView, {
      onChange: (blocks) => this.onSuggestionsChange?.(blocks)
    })
  }

  destroy() {
    this.aiSuggestions?.destroy()
    this.aiSuggestions = null
    this.editorView.dom.remove()
    this.editorView = null
  }

  focus() {
    this.editorView.focus()
  }

  getContent() {
    return this.editorView.state.doc.toString()
  }

  setContent(content) {
    const current = this.editorView.state.doc.toString()
    if (current === content) return

    this.editorView.dispatch({
      changes: { from: 0, to: current.length, insert: content }
    })
  }

  insertText(text) {
    const range = this.editorView.state.selection.ranges[0]

    this.editorView.dispatch({
      changes: { from: range.from, to: range.to, insert: text },
      selection: { anchor: range.from + text.length }
    })
  }

  findAndReplace(findText, replaceText, { replaceAll = false } = {}) {
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
      this.editorView.dispatch({ changes })
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

  // --- AI suggestions (delegated to the AiSuggestionLayer in ./suggestions) --

  appendSuggestionBlock(block) {
    this.aiSuggestions?.appendSuggestionBlock(block)
  }

  acceptSuggestion(id) {
    this.aiSuggestions?.acceptSuggestion(id)
  }

  rejectSuggestion(id) {
    this.aiSuggestions?.rejectSuggestion(id)
  }

  acceptAllSuggestions() {
    this.aiSuggestions?.acceptAllSuggestions()
  }

  rejectAllSuggestions() {
    this.aiSuggestions?.rejectAllSuggestions()
  }

  clearContentSuggestions() {
    this.aiSuggestions?.rejectAllSuggestions()
  }

  get pendingContentCount() {
    return this.aiSuggestions?.pendingContentCount ?? 0
  }

  get hasRewritePending() {
    return this.aiSuggestions?.hasRewritePending ?? false
  }
}

export { MarkdownMirror }
