import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    placeholder: String,
    creatable: Boolean,
    maxItems: Number
  }

  static targets = ["chip", "item"]

  connect() {
    this.element[this.identifier] = this;

    this.selectTarget = this.element.querySelector('select')
    this.multiple = this.selectTarget.multiple

    if (!this.multiple) {
      this.maxItemsValue = 1
    }

    this.container = document.createElement('div')
    this.container.className = 'selector__container'
    this.element.appendChild(this.container)

    if (!this.multiple) {
      this.text = document.createElement('div')
      this.text.className = 'selector__text'
      this.container.appendChild(this.text)
    }

    this.input = document.createElement('input')
    this.input.type = 'text'
    this.input.className = 'selector__input'
    this.setPlaceholder()
    this.container.appendChild(this.input)

    this.menu = document.createElement('div')
    this.menu.className = 'selector__menu'
    this.element.appendChild(this.menu)

    this.initOptions()

    // remove unselect option to keep output order
    Array.from(this.selectTarget.options).forEach((option) => {
      if (!option.selected) {
        option.remove()
      }
    })

    if (this.multiple) {
      this.options.forEach((option) => {
        if (option.selected) {
          this.appendChip(option)
        }
      })
    } else {
      this.options.forEach((option) => {
        if (option.selected) {
          this.text.textContent = option.text
        }
      })
    }

    this.renderMenu()

    this.input.addEventListener('focus', this.focus.bind(this))
    this.input.addEventListener('input', this.onInput.bind(this))
    this.input.addEventListener('keydown', this.onKeydown.bind(this))

    this.clickOutside = (event) => {
      if (!this.element.contains(event.target)) {
        this.blur()
      }
    }
  }

  disconnect() {
    this.blur()
    this.container.remove()
    this.menu.remove()

    // restore unselect option for next time connect
    this.options.forEach((option) => {
      if (!option.selected) {
        this.addOptionDom(option)
      }
    })
  }

  maxItemsLimit() {
    return this.maxItemsValue && this.selectTarget.selectedOptions.length >= this.maxItemsValue
  }

  setPlaceholder() {
    if (this.maxItemsLimit()) {
      this.input.removeAttribute('placeholder')
    } else {
      this.input.setAttribute('placeholder', this.placeholderValue)
    }
  }

  initOptions() {
    this.options = Array.from(this.selectTarget.options).map(option => {
      return {
        text: option.text, value: option.value, selected: option.selected
      }
    })
  }

  renderMenu() {
    this.menu.innerHTML = ''
    if (this.multiple && this.maxItemsLimit()) {
      this.computedOptions = []
    } else {
      this.computedOptions = this.filterOptions(this.input.value)

      let createOption
      if (this.creatableValue) {
        createOption = this.createOption(this.input.value)
        if (createOption) {
          this.computedOptions.unshift(createOption)
        }
      }

      this.computedOptions.forEach((option) => {
        let dom = this.htmlToElement(this.renderItem(option))
        this.menu.appendChild(dom)
      })

      // reset focus
      if (this.computedOptions.length > 0) {
        if (this.multiple) {
          if (createOption && this.computedOptions.length > 1) {
            this.focusItem(1)
          } else {
            this.focusItem(0)
          }
        } else {
          let selectedIndex = this.computedOptions.findIndex(option => option.selected)
          if (selectedIndex != -1) {
            this.focusItem(selectedIndex)
          } else {
            this.focusItem(0)
          }
        }
      }
    }
  }

  createOption(input) {
    if (input && input.length > 0) {
      return { text: `${input}`, value: input, create: true }
    } else {
      return false
    }
  }

  onInput() {
    const notPrevented = this.element.dispatchEvent(new CustomEvent('selector:input', { detail: { value: this.input.value }, cancelable: true }))

    if (notPrevented) {
      this.renderMenu()
    }
  }

  onKeydown(event) {
    if (this.maxItemsLimit()) {
      event.preventDefault()
    }

    if (!event.isComposing) {
      switch (event.keyCode) {
        case 13: // Enter
          // avoid trigger form submit
          event.preventDefault()
          this.selectFocus()
          break;
        case 8: // Backspace
          this.removeLast()
          break;
        case 38: // ArrowUp
          this.focusPrev()
          break;
        case 40: // ArrowDown
          this.focusNext()
          break;
      }
    }
  }

  selectFocus() {
    if (this.computedOptions.length) {
      let focusOption = this.computedOptions[this.focusIndex]
      this.addSelected(focusOption)
    }
  }

  removeLast() {
    if (this.input.value == '') {
      let lastOptionDom = this.selectTarget.options[this.selectTarget.options.length - 1]
      if (lastOptionDom) {
        this.removeSelected(lastOptionDom.value)
        this.renderMenu()
      }
    }
  }

  focusItem(index) {
    this.focusIndex = index
    let option = this.computedOptions[index]

    let prevFocusItem = this.element.querySelector('.selector__item--focus')
    if (prevFocusItem) {
      prevFocusItem.classList.remove('selector__item--focus')
    }

    this.itemTargets[this.focusIndex].classList.add('selector__item--focus')
  }

  focusPrev() {
    if (this.computedOptions.length > 0) {
      if (this.focusIndex > 0) {
        this.focusItem(this.focusIndex - 1)
      } else {
        this.focusItem(this.computedOptions.length - 1)
      }
    }
  }

  focusNext() {
    if (this.computedOptions.length > 0) {
      if (this.focusIndex < this.computedOptions.length - 1) {
        this.focusItem(this.focusIndex + 1)
      } else {
        this.focusItem(0)
      }
    }
  }

  // for single select, all option is visible
  // for multiple select, ignore selected option
  filterOptions(input) {
    if (this.multiple) {
      return this.options.filter(option => !option.selected &&  option.text.toLowerCase().includes(input.toLowerCase()))
    } else {
      return this.options.filter(option => option.text.toLowerCase().includes(input.toLowerCase()))
    }
  }

  htmlToElement(html) {
    let template = document.createElement('template')
    template.innerHTML = html.trim()
    return template.content.firstChild
  }

  renderItem(option) {
    return `
      <div class="selector__item" data-value="${option.value}" data-selector-target="item" data-action="click->selector#select">
        ${ option.create ? `Add ${option.text}...` : option.text }
      </div>
    `
  }

  appendChip(option) {
    let chip = this.htmlToElement(this.renderChip(option))
    this.container.insertBefore(chip, this.input)
  }

  renderChip(option) {
    return `
      <div class="chip chip--input" data-value="${option.value}" data-selector-target="chip">
        ${option.text}
        <div class="chip__action">
          <button type="button" class="button button--icon" data-action="selector#unselect">
            <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24"><path d="M0 0h24v24H0V0z" fill="none" opacity=".87"/><path d="M12 2C6.47 2 2 6.47 2 12s4.47 10 10 10 10-4.47 10-10S17.53 2 12 2zm4.3 14.3c-.39.39-1.02.39-1.41 0L12 13.41 9.11 16.3c-.39.39-1.02.39-1.41 0-.39-.39-.39-1.02 0-1.41L10.59 12 7.7 9.11c-.39-.39-.39-1.02 0-1.41.39-.39 1.02-.39 1.41 0L12 10.59l2.89-2.89c.39-.39 1.02-.39 1.41 0 .39.39.39 1.02 0 1.41L13.41 12l2.89 2.89c.38.38.38 1.02 0 1.41z"/></svg>
          </button>
        </div>
      </div>
    `
  }

  focus() {
    this.element.classList.add('selector--focus')
    document.addEventListener('click', this.clickOutside)
  }

  blur() {
    this.element.classList.remove('selector--focus')
    document.removeEventListener('click', this.clickOutside)
  }

  unselect(event) {
    event.stopPropagation()
    let chip = event.currentTarget.closest('.chip')
    this.removeSelected(chip.dataset.value)
    this.renderMenu()
  }

  getOption(value) {
    return this.options.find(option => option.value == value)
  }

  select(event) {
    event.stopPropagation()
    let item = event.currentTarget
    let option = this.computedOptions.find(option => option.value == item.dataset.value)
    this.addSelected(option)
  }

  addSelected(option) {
    if (!option.selected) {
      option.selected = true

      if (this.multiple) {
        this.addOptionDom(option)
        this.appendChip(option)
      } else {
        this.selectTarget.innerHTML = ''
        this.addOptionDom(option)
        this.text.textContent = option.text

        this.options.forEach((otherOption) => {
          if (otherOption != option) {
            otherOption.selected = false
          }
        })
      }

      this.setPlaceholder()

      this.selectTarget.dispatchEvent(new Event('change', { bubbles: true }))
    }

    this.input.value = ''
    this.renderMenu()
    if (this.multiple) {
      this.input.focus()
    } else {
      this.input.blur()
      this.blur()
    }
  }

  addOptionDom(option) {
    let dom = document.createElement('option')
    dom.value = option.value
    dom.text = option.text
    dom.setAttribute('selected', option.selected)
    this.selectTarget.appendChild(dom)
  }

  removeSelected(value) {
    Array.from(this.selectTarget.options).forEach((option) => {
      if (option.value == value) {
        option.remove()
      }
    })

    if (this.multiple) {
      this.chipTargets.forEach((chip) => {
        if (chip.dataset.value == value) {
          chip.remove()
        }
      })
    } else {
      this.text.textContent = ''
    }

    this.setPlaceholder()

    this.options.forEach((storeOption) => {
      if (storeOption.value == value) {
        storeOption.selected = false
      }
    })

    this.selectTarget.dispatchEvent(new Event('change', { bubbles: true }))
  }
}
