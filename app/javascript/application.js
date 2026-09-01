import "./controllers"
import "./turbo_stream_actions"
import "@hotwired/turbo-rails"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import LocalTime from "local-time"
LocalTime.start()
