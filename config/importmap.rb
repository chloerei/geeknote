# Pin npm packages by running ./bin/importmap

pin "application"

pin "@hotwired/turbo-rails", to: "turbo.min.js"

pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "@rails/activestorage", to: "activestorage.esm.js"
pin "local-time", to: "local-time.es2017-esm.js"

pin "markdown-mirror"
pin_all_from "app/javascript/lib", under: "lib"
