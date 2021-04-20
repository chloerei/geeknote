// import Rails from "@rails/ujs"
// Rails.start()

import "@hotwired/turbo-rails"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import './channels'

import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

const application = Application.start()

import { init } from "campo-ui/src/js/campo-ui"
init(application)

const context = require.context("./controllers", true, /\.js$/)
application.load(definitionsFromContext(context))
