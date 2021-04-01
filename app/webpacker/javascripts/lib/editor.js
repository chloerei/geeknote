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

class Editor {
  constructor(element, options = {}) {
    this.editorView = new EditorView({
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
          markdown(),
          toolbar(options)
        ]
      }),
      parent: element
    })
  }
}

export { Editor }
