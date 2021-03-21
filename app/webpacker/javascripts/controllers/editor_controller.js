import { Controller } from "stimulus"

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

export default class extends Controller {
  connect() {
    let view = new EditorView({
      state: EditorState.create({
        extensions: [
          history(),
          indentOnInput(),
          classHighlightStyle,
          bracketMatching(),
          closeBrackets(),
          placeholder('Write post here'),
          keymap.of([
            ...closeBracketsKeymap,
            ...defaultKeymap,
            ...historyKeymap,
          ]),
          markdown()
        ]
      }),
      parent: this.element
    })
  }
}
