import { Controller } from "@hotwired/stimulus"
import { post } from '@rails/request.js'
import { DirectUpload } from "@rails/activestorage"

import { EditorView, ViewPlugin, keymap, placeholder } from "@codemirror/view"
import { EditorState, EditorSelection } from "@codemirror/state"
import { indentOnInput, bracketMatching, syntaxHighlighting, HighlightStyle } from "@codemirror/language"
import { defaultKeymap, history, historyKeymap } from "@codemirror/commands"
import { closeBrackets, closeBracketsKeymap } from "@codemirror/autocomplete"
import { markdown } from "@codemirror/lang-markdown"
import { tags } from "@lezer/highlight"

import { StyleModule } from "style-mod"
StyleModule.mount = () => { /* Disabled it ! */ }

const classHighlightStyle = HighlightStyle.define([
  {tag: tags.link, class: "cmt-link"},
  {tag: tags.heading, class: "cmt-heading"},
  {tag: tags.emphasis, class: "cmt-emphasis"},
  {tag: tags.strong, class: "cmt-strong"},
  {tag: tags.keyword, class: "cmt-keyword"},
  {tag: tags.atom, class: "cmt-atom"},
  {tag: tags.bool, class: "cmt-bool"},
  {tag: tags.url, class: "cmt-url"},
  {tag: tags.labelName, class: "cmt-labelName"},
  {tag: tags.inserted, class: "cmt-inserted"},
  {tag: tags.deleted, class: "cmt-deleted"},
  {tag: tags.literal, class: "cmt-literal"},
  {tag: tags.string, class: "cmt-string"},
  {tag: tags.number, class: "cmt-number"},
  {tag: [tags.regexp, tags.escape, tags.special(tags.string)], class: "cmt-string2"},
  {tag: tags.variableName, class: "cmt-variableName"},
  {tag: tags.local(tags.variableName), class: "cmt-variableName cmt-local"},
  {tag: tags.definition(tags.variableName), class: "cmt-variableName cmt-definition"},
  {tag: tags.special(tags.variableName), class: "cmt-variableName2"},
  {tag: tags.definition(tags.propertyName), class: "cmt-propertyName cmt-definition"},
  {tag: tags.typeName, class: "cmt-typeName"},
  {tag: tags.namespace, class: "cmt-namespace"},
  {tag: tags.className, class: "cmt-className"},
  {tag: tags.macroName, class: "cmt-macroName"},
  {tag: tags.propertyName, class: "cmt-propertyName"},
  {tag: tags.operator, class: "cmt-operator"},
  {tag: tags.comment, class: "cmt-comment"},
  {tag: tags.meta, class: "cmt-meta"},
  {tag: tags.invalid, class: "cmt-invalid"},
  {tag: tags.punctuation, class: "cmt-punctuation"}
])

export default class extends Controller {
  static values = {
    input: String,
    directUploadUrl: String
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
        <button type="button" class="button button--icon" tabindex="-1" data-action="markdown-editor#formatBold">
          <span class="material-icons">format_bold</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1" data-action="markdown-editor#formatItalic">
          <span class="material-icons">format_italic</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1" data-action="markdown-editor#formatTitle">
          <span class="material-icons">title</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1" data-action="markdown-editor#formatCode">
          <span class="material-icons">code</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1" data-action="markdown-editor#formatQuote">
          <span class="material-icons">format_quote</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1" data-action="markdown-editor#formatListBulleted">
          <span class="material-icons">format_list_bulleted</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1" data-action="markdown-editor#formatListNumbered">
          <span class="material-icons">format_list_numbered</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1" data-action="markdown-editor#formatLink">
          <span class="material-icons">insert_link</span>
        </button>
        <button type="button" class="button button--icon" tabindex="-1" data-action="markdown-editor#formatImage">
          <span class="material-icons">add_photo_alternate</span>
          <input type="file" class="display-none" data-action="markdown-editor#formatImage">
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
          syntaxHighlighting(classHighlightStyle, { fallback: true }),
          bracketMatching(),
          closeBrackets(),
          placeholder(this.inputElement ? this.inputElement.placeholder : ''),
          keymap.of([
            ...closeBracketsKeymap,
            ...defaultKeymap,
            ...historyKeymap,
          ]),
          markdown(),
          // sync doc value to inputElement
          ViewPlugin.define((view) => {
            return {
              update: (viewUpdate) => {
                if (this.inputElement && viewUpdate.docChanged) {
                  this.inputElement.value = view.state.doc.toString()
                  this.inputElement.dispatchEvent(new Event('input', { bubbles: true }))
                }
              }
            }
          }),
          EditorView.domEventHandlers({
            focus: (event, view) => {
              this.element.classList.add('markdown-editor--focus')
            },
            blur: (event, view) => {
              this.element.classList.remove('markdown-editor--focus')
            },
            // Uplaod image from clipboard
            paste: (event, view) => {
              if (event.clipboardData.files.length) {
                event.preventDefault()
                this.uploadImages(event.clipboardData.files)
              }
            }
          })
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

  formatBold() {
    this.wrapSelection('**')
  }

  formatItalic() {
    this.wrapSelection('*')
  }

  formatTitle() {
    this.linePrepend('## ')
  }

  formatCode() {
    this.editorView.dispatch(
      this.editorView.state.changeByRange(range => {
        let lineFrom = this.editorView.state.doc.lineAt(range.from)
        let lineTo = this.editorView.state.doc.lineAt(range.to)

        if (lineFrom.number != lineTo.number || (lineFrom.from == range.from && lineTo.to == range.to)) {
          return {
            changes: [{ from: lineFrom.from, insert: "```\n" }, { from: lineTo.to, insert: "\n```"}],
            range: EditorSelection.range(lineFrom.from + 3, lineFrom.from + 3)
          }
        } else {
          return {
            changes: [{ from: range.from, insert: '`' }, { from: range.to, insert: '`'}],
            range: EditorSelection.range(range.from + 1, range.to + 1)
          }
        }
      })
    )
    this.editorView.focus()
  }

  formatQuote() {
    this.linePrepend('> ')
  }

  formatListBulleted() {
    this.linePrepend('- ')
  }

  formatListNumbered() {
    let number = 1
    this.editorView.dispatch(this.editorView.state.changeByRange(range => {
      let changes = []
      for (let pos = range.from; pos <= range.to;) {
        let line = this.editorView.state.doc.lineAt(pos)
        changes.push({ from: line.from, insert: number + '. ' })
        pos = line.to + 1
        number = number + 1
      }

      let changeSet = this.editorView.state.changes(changes)

      return {
        changes,
        range: EditorSelection.range(changeSet.mapPos(range.anchor, 1), changeSet.mapPos(range.head, 1))
      }
    }))
    this.editorView.focus()
  }

  formatLink() {
    this.editorView.dispatch(
      this.editorView.state.changeByRange(range => {
        let text = this.editorView.state.sliceDoc(range.from, range.to)
        if (text == '') {
          text = 'text'
        }

        let url = 'url'

        return {
          changes: [{ from: range.from, to: range.to, insert: `[${text}](${url})` }],
          range: EditorSelection.range(range.from + text.length + 3, range.from + text.length + url.length + 3)
        }
      })
    )
    this.editorView.focus()
  }

  formatImage() {
    let input = document.createElement('input')
    input.type = 'file'
    input.multiple = true
    input.accept = 'image/*'

    input.onchange = (event) => {
      console.log(event)
      this.uploadImages(event.target.files)
    }

    input.click()
  }

  uploadImages(files) {
    this.editorView.dispatch(
      this.editorView.state.changeByRange(range => {
        let changes = [{ from: range.from, to: range.to, insert: '' }]
        let end = range.from

        Array.from(files).forEach(async (file) => {
          if ((file.size > 10 * 1024 * 1024) || (!["image/jpeg", "image/png", "image/gif"].includes(file.type))) {
            // File size limit
          } else {
            let placeholder = `![uploading_${file.name}]()`
            changes.push({ from: range.to, insert: placeholder + "\n" })
            end += (placeholder.length + 1)

            const url = await this.uploadImage(file)

            let pos = this.editorView.state.doc.toString().indexOf(placeholder)
            if (pos > -1) {
              let text = `![${file.name}](${url})`
              this.editorView.dispatch({
                changes: { from: pos, to: pos + placeholder.length, insert: text}
              })
            }
          }
        })

        return {
          changes: changes,
          range: EditorSelection.range(end, end)
        }
      })
    )
    this.editorView.focus()
  }

  uploadImage(file) {
    const directUploadUrl = this.directUploadUrlValue
    return new Promise(function(resolve, reject) {
      const upload = new DirectUpload(file, directUploadUrl)
      upload.create(async (error, blob) => {
        if (error) {
          // error
        } else {
          let formData = new FormData()
          formData.append('attachment[file]', blob.signed_id)
          const response = await post('/attachments', {
              body: formData
            }
          )
          if (response.ok) {
            const json = await response.json
            resolve(json.url)
          }
        }
      })
    })
  }

  wrapSelection(mark) {
    this.editorView.dispatch(this.editorView.state.changeByRange(range => ({
      changes: [{ from: range.from, insert: mark }, { from: range.to, insert: mark}],
      range: EditorSelection.range(range.from + mark.length, range.to + mark.length)
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
