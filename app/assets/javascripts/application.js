import "@hotwired/turbo"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import LocalTime from "local-time"
LocalTime.start()

import './channels'

import "./controllers"

// color scheme
document.addEventListener('DOMContentLoaded', () => {
  document.documentElement.dataset.colorScheme = localStorage.getItem('color-scheme') || 'default'
})
