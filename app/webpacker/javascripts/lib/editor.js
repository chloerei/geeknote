import { EditorView, keymap, placeholder } from "@codemirror/view"
import { Extension, EditorState } from "@codemirror/state"
import { history, historyKeymap } from "@codemirror/history"
import { indentOnInput } from "@codemirror/language"
import { defaultKeymap } from "@codemirror/commands"
import { bracketMatching } from "@codemirror/matchbrackets"
import { closeBrackets, closeBracketsKeymap } from "@codemirror/closebrackets"
import { classHighlightStyle } from "@codemirror/highlight"
import { markdown } from "@codemirror/lang-markdown"

import { StyleModule } from "style-mod"
StyleModule.mount = () => { /* Disabled it ! */ }

import { toolbar } from './editor/toolbar'
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
          toolbar(options),
          syncInput(this.options.input),
          scrollMargin()
        ]
      }),
      parent: element
    })
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
