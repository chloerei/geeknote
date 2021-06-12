import { ViewPlugin } from "@codemirror/view"
import { EditorSelection } from "@codemirror/state"

class ToolbarItem {
  // options:
  //   - icon
  //   - command(view)
  //   - active(update)
  constructor(view, options) {
    this.view = view
    this.options = options

    let button = document.createElement('button')
    button.type = 'button'
    button.className = 'editor-toolbar__button'
    button.innerHTML = options.icon
    button.tabIndex = '-1'

    this.dom = button

    this.dom.addEventListener('click', () => {
      this.options.command(this.view)
    })
  }
}

function markCommand(mark) {
  return function(view) {
    view.dispatch(view.state.changeByRange(range => ({
      changes: [{ from: range.from, insert: mark }, { from: range.to, insert: mark}],
      range: EditorSelection.range(range.from + mark.length, range.to + mark.length)
    })))
    view.focus()
  }
}

function linePrependCommand(mark) {
  return function(view) {
    view.dispatch(view.state.changeByRange(range => {
      let changes = []
      for (let pos = range.from; pos <= range.to;) {
        let line = view.state.doc.lineAt(pos)
        changes.push({ from: line.from, insert: mark })
        pos = line.to + 1
      }

      let changeSet = view.state.changes(changes)

      return {
        changes,
        range: EditorSelection.range(changeSet.mapPos(range.anchor, 1), changeSet.mapPos(range.head, 1))
      }
    }))
    view.focus()
  }
}

function insertLink(view) {
  view.dispatch(
    view.state.changeByRange(range => {
      let text = view.state.sliceDoc(range.from, range.to)
      if (text == '') {
        text = 'text'
      }

      let url = 'https://'

      return {
        changes: [{ from: range.from, to: range.to, insert: `[${text}](${url})` }],
        range: EditorSelection.range(range.from + text.length + 3, range.from + text.length + url.length + 3)
      }
    })
  )
  view.focus()
}

function wrapCode(view) {
  view.dispatch(
    view.state.changeByRange(range => {
      let lineFrom = view.state.doc.lineAt(range.from)
      let lineTo = view.state.doc.lineAt(range.to)

      if (lineFrom.number != lineTo.number || (lineFrom.from == range.from && lineTo.to == range.to)) {
        return {
          changes: [{ from: lineFrom.from, insert: "```lang\n" }, { from: lineTo.to, insert: "\n```"}],
          range: EditorSelection.range(lineFrom.from + 3, lineFrom.from + 7)
        }
      } else {
        return {
          changes: [{ from: range.from, insert: '`' }, { from: range.to, insert: '`'}],
          range: EditorSelection.range(range.from + 1, range.to + 1)
        }
      }
    })
  )
  view.focus()
}

function uploadImage(options) {
  return function(view) {
    if (!options.uploadImage) {
      alert('undefine options.uploadImage')
    }

    let input = document.createElement('input')
    input.type = 'file'
    input.multiple = true
    input.accept = 'image/*'

    input.onchange = (event) => {
      view.dispatch(
        view.state.changeByRange(range => {
          let changes = []
          let end = range.to

          Array.from(event.target.files).forEach((file) => {
            let placeholder = `![uploading_${file.name}]()`
            changes.push({ from: range.to, insert: placeholder + "\n" })
            end += (placeholder.length + 1)
            options.uploadImage(file).then((url) => {
              let pos = view.state.doc.toString().indexOf(placeholder)
              if (pos > -1) {
                let text = `![${file.name}](${url})`
                view.dispatch({
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
      view.focus()
    }

    input.click()
  }
}

function toolbarItems(options) {
  return {
    bold: {
      icon: '<span class="material-icons">format_bold</span>',
      command: markCommand('**')
    },
    italic: {
      icon: '<span class="material-icons">format_italic</span>',
      command: markCommand('_')
    },
    bulleted_list: {
      icon: '<span class="material-icons">format_list_bulleted</span>',
      command: linePrependCommand('- ')
    },
    ordered_list: {
      icon: '<span class="material-icons">format_list_numbered</span>',
      command: linePrependCommand('1. ')
    },
    link: {
      icon: '<span class="material-icons">insert_link</span>',
      command: insertLink
    },
    image: {
      icon: '<span class="material-icons">add_photo_alternate</span>',
      command: uploadImage(options)
    },
    quote: {
      icon: '<span class="material-icons">format_quote</span>',
      command: linePrependCommand('> ')
    },
    code: {
      icon: '<span class="material-icons">code</span>',
      command: wrapCode
    },
  }
}

class ToolbarPlugin {
  constructor(view, options) {
    this.view = view
    this.dom = document.createElement('div')
    this.dom.className = 'editor-toolbar'
    this.options = options

    this.toolbarItems = toolbarItems(this.options)

    for (const name in this.toolbarItems) {
      let item = new ToolbarItem(this.view, this.toolbarItems[name])
      this.dom.appendChild(item.dom)
    }

    if (this.options.toolbar.parent) {
      this.options.toolbar.parent.innerHTML = ''
      this.options.toolbar.parent.appendChild(this.dom)
    } else {
      view.dom.insertBefore(this.dom, view.dom.firstChild)
    }
  }

  update(viewUpdate) {
  }

  destroy() {
  }
}

export function toolbar(options) {
  return ViewPlugin.define(view => new ToolbarPlugin(view, options))
}
