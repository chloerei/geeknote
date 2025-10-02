import "./controllers"
import "@hotwired/turbo-rails"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import LocalTime from "local-time"
LocalTime.start()

import ahoy from "ahoy.js"

window.ahoy = ahoy
