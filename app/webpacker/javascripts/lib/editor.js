import { EditorView, keymap, placeholder } from "@codemirror/view"
import { Extension, EditorState, EditorSelection } from "@codemirror/state"
import { history, historyKeymap } from "@codemirror/history"
import { indentOnInput } from "@codemirror/language"
import { defaultKeymap } from "@codemirror/commands"
import { bracketMatching } from "@codemirror/matchbrackets"
import { closeBrackets, closeBracketsKeymap } from "@codemirror/closebrackets"
import { classHighlightStyle } from "@codemirror/highlight"
import { markdown } from "@codemirror/lang-markdown"

import { StyleModule } from "style-mod"
StyleModule.mount = () => { /* Disabled it ! */ }

import { syncInput } from './editor/sync_input'
import { scrollMargin } from './editor/scroll_margin'

class Editor {
  constructor(element, options = {}) {
    this.element = element
    this.options = options
    this.element.innerHTML = ''
    this.editorView = new EditorView({
      state: EditorState.create({
        doc: this.options.input ? this.options.input.value : '',
        extensions: [
          history(),
          indentOnInput(),
          classHighlightStyle,
          bracketMatching(),
          closeBrackets(),
          placeholder(options.placeholder),
          keymap.of([
            ...closeBracketsKeymap,
            ...defaultKeymap,
            ...historyKeymap,
          ]),
          markdown(),
          syncInput(this.options.input),
          scrollMargin(),
          EditorView.domEventHandlers({
            drop: (event, view) => {
              if (event.dataTransfer.files.length) {
                event.preventDefault()
                this.uploadImages(event.dataTransfer.files)
              }
            },
            paste: (event, view) => {
              if (event.clipboardData.files.length) {
                event.preventDefault()
                this.uploadImages(event.clipboardData.files)
              }
            }
          })
        ]
      }),
      parent: element
    })
  }

  uploadImages(files) {
    this.editorView.dispatch(
      this.editorView.state.changeByRange(range => {
        let changes = [{ from: range.from, to: range.to, insert: '' }]
        let end = range.from

        Array.from(files).forEach((file) => {
          let placeholder = `![uploading_${file.name}]()`
          changes.push({ from: range.to, insert: placeholder + "\n" })
          end += (placeholder.length + 1)
          this.options.uploadImage(file).then((url) => {
            let pos = this.editorView.state.doc.toString().indexOf(placeholder)
            if (pos > -1) {
              let text = `![${file.name}](${url})`
              this.editorView.dispatch({
                changes: { from: pos, to: pos + placeholder.length, insert: text}
              })
            }
          })
        })

        return {
          changes: changes,
          range: EditorSelection.range(end, end)
        }
      })
    )
    this.editorView.focus()
  }

  focus() {
    this.editorView.focus()
  }

  focusEnd() {
    this.editorView.dispatch({
      selection: { anchor: this.editorView.state.doc.length }
    })
    this.editorView.focus()
  }
}

export { Editor }
