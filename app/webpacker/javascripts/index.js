import Rails from "@rails/ujs"
Rails.start()

import "@hotwired/turbo-rails"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import './channels'

import { application } from 'campo-ui/src/js/campo-ui'
import { definitionsFromContext } from "stimulus/webpack-helpers"

const context = require.context("./controllers", true, /\.js$/)
application.load(definitionsFromContext(context))
