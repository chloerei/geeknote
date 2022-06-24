import { Controller } from "@hotwired/stimulus"
import { post } from '@rails/request.js'

import { EditorView, keymap, placeholder } from "@codemirror/view"
import { EditorState, EditorSelection } from "@codemirror/state"
import { history, historyKeymap } from "@codemirror/history"
import { indentOnInput } from "@codemirror/language"
import { defaultKeymap } from "@codemirror/commands"
import { bracketMatching } from "@codemirror/matchbrackets"
import { closeBrackets, closeBracketsKeymap } from "@codemirror/closebrackets"
import { classHighlightStyle } from "@codemirror/highlight"
import { markdown } from "@codemirror/lang-markdown"

export default class extends Controller {
  static values = {
    input: String
  }

  static targets = ["content", "preview"]

  connect() {
    this.element.innerHTML = `
      <div class="markdown-editor__toolbar">
        <button type="button" class="button button--text markdown-editor__write-button"  data-action="markdown-editor#write" tabindex="-1">
          <div class="button__icon">
            <span class="material-icons">edit</span>
          </div>
          <div class="button__label">
            Write
          </div>
        </button>
        <button type="button" class="button button--text markdown-editor__preview-button" data-action="markdown-editor#preview" tabindex="-1">
          <div class="button__icon">
            <span class="material-icons">preview</span>
          </div>
          <div class="button__label">
            Preview
          </div>
        </button>
        <div class="flex-grow-1">
        </div>
        <button type="button" class="button button--icon" tabindex="-1">
          <span class="material-icons">format_bold</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1">
          <span class="material-icons">format_italic</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1">
          <span class="material-icons">title</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1">
          <span class="material-icons">code</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1">
          <span class="material-icons">format_quote</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1">
          <span class="material-icons">format_list_bulleted</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1">
          <span class="material-icons">format_list_numbered</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1">
          <span class="material-icons">insert_link</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1">
          <span class="material-icons">add_photo_alternate</span>
        </button>
      </div>
      <div class="markdown-editor__content" data-markdown-editor-target="content">
      </div>
      <div class="markdown-editor__preview typography" data-markdown-editor-target="preview">
      </div>
    `

    if (this.inputValue) {
      this.inputElement = document.getElementById(this.inputValue)
    }

    this.editorView = new EditorView({
      state: EditorState.create({
        doc: this.inputElement ? this.inputElement.value : '',
        extensions: [
          history(),
          indentOnInput(),
          classHighlightStyle,
          bracketMatching(),
          closeBrackets(),
          // placeholder('placeholder'),
          keymap.of([
            ...closeBracketsKeymap,
            ...defaultKeymap,
            ...historyKeymap,
          ]),
          markdown(),
          // syncInput(this.options.input),
          // EditorView.domEventHandlers({
          //   paste: (event, view) => {
          //     if (event.clipboardData.files.length) {
          //       event.preventDefault()
          //       this.uploadImages(event.clipboardData.files)
          //     }
          //   }
          // })
        ]
      }),
      parent: this.contentTarget
    })
  }

  async preview() {
    const response = await post('/preview', {
      body: {
        content: this.editorView.state.doc.toString()
      }
    })

    if (response.ok) {
      this.previewTarget.innerHTML = await response.text
      this.element.classList.add('markdown-editor--previewing')
    }

  }

  write() {
    this.element.classList.remove('markdown-editor--previewing')
  }
}
