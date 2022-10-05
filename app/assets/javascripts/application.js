import "@hotwired/turbo"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import LocalTime from "local-time"
LocalTime.start()

import './channels'

import { Application } from "@hotwired/stimulus"

const application = Application.start()

import SelectorController from './controllers/selector_controller'
application.register('selector', SelectorController)

import ClipboardController from './controllers/clipboard_controller'
application.register('clipboard', ClipboardController)

import CollectionItemController from './controllers/collection_item_controller'
application.register('collection-item', CollectionItemController)

import DraggableController from './controllers/draggable_controller'
application.register('draggable', DraggableController)

import FieldsetManagerController from './controllers/fieldset_manager_controller'
application.register('fieldset-manager', FieldsetManagerController)

import FocusableController from './controllers/focusable_controller'
application.register('focusable', FocusableController)

import FormController from './controllers/form_controller'
application.register('form', FormController)

import PageNavController from './controllers/page_nav_controller'
application.register('page-nav', PageNavController)

import PaginationController from './controllers/pagination_controller'
application.register('pagination', PaginationController)

// import PostEditorController from './controllers/post_editor_controller'
// application.register('post-editor', PostEditorController)
//
import PostListController from './controllers/post_list_controller'
application.register('post-list', PostListController)

import PostFormController from './controllers/post_form_controller'
application.register('post-form', PostFormController)

import RevisionController from './controllers/revision_controller'
application.register('revision', RevisionController)

import SortableController from './controllers/sortable_controller'
application.register('sortable', SortableController)

import TagSelectorController from './controllers/tag_selector_controller'
application.register('tag-selector', TagSelectorController)

import ThemeSettingsController from './controllers/theme_settings_controller'
application.register('theme-settings', ThemeSettingsController)

import ImageUploaderController from './controllers/image_uploader_controller'
application.register('image-uploader', ImageUploaderController)

import MarkdownEditorController from './controllers/markdown_editor_controller'
application.register('markdown-editor', MarkdownEditorController)

import CommentController from './controllers/comment_controller'
application.register('comment', CommentController)

import SnackbarController from './controllers/snackbar_controller'
application.register('snackbar', SnackbarController)

import TextFieldController from './controllers/text_field_controller'
application.register('text-field', TextFieldController)

import RecaptchaController from './controllers/recaptcha_controller'
application.register('recaptcha', RecaptchaController)

import AutoGrowController from './controllers/auto_grow_controller'
application.register('auto-grow', AutoGrowController)

import './lib/turbo_preserve_scroll'

// clean snackbar content
document.addEventListener('turbo:before-cache', () => {
  document.getElementById('snackbar-container').innerHTML = ''
})

// color scheme
document.addEventListener('DOMContentLoaded', () => {
  document.body.dataset.colorScheme = localStorage.getItem('color-scheme') || 'default'
})

document.addEventListener('turbo:before-render', (event) => {
  event.detail.newBody.dataset.colorScheme = localStorage.getItem('color-scheme') || 'default'
})
