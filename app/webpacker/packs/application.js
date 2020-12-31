import 'javascripts'
import 'stylesheets'

let imageContext = require.context('images/', true)
imageContext.keys().forEach(imageContext)
