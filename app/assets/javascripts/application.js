import "@hotwired/turbo"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import LocalTime from "local-time"
LocalTime.start()

import './channels'

import "./controllers"

// color scheme
document.addEventListener('DOMContentLoaded', () => {
  document.body.dataset.colorScheme = localStorage.getItem('color-scheme') || 'default'
})

document.addEventListener('turbo:before-render', (event) => {
  event.detail.newBody.dataset.colorScheme = localStorage.getItem('color-scheme') || 'default'
})
