import Rails from "@rails/ujs"
Rails.start()

import "@hotwired/turbo-rails"

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import LocalTime from "local-time"
LocalTime.start()

import './channels'

import { Application } from "stimulus"

const application = Application.start()

import { init } from "campo-ui/src/js/campo-ui"
init(application)

import ClipboardController from './controllers/clipboard_controller'
application.register('clipboard', ClipboardController)

import CollectionItemController from './controllers/collection_item_controller'
application.register('collection_item', CollectionItemController)

import DraggableController from './controllers/draggable_controller'
application.register('draggable', DraggableController)

import FieldsetManagerController from './controllers/fieldset_manager_controller'
application.register('fieldset-manager', FieldsetManagerController)

import FocusableController from './controllers/focusable_controller'
application.register('focusable', FocusableController)

import FormController from './controllers/form_controller'
application.register('form', FormController)

import PageFrameController from './controllers/page_frame_controller'
application.register('page-frame', PageFrameController)

import PageNavController from './controllers/page_nav_controller'
application.register('page-nav', PageNavController)

import PaginationController from './controllers/pagination_controller'
application.register('pagination', PaginationController)

import PostEditorController from './controllers/post_editor_controller'
application.register('post-editor', PostEditorController)

import PostListController from './controllers/post_list_controller'
application.register('post-list', PostListController)

import RevisionController from './controllers/revision_controller'
application.register('revision', RevisionController)

import SortableController from './controllers/sortable_controller'
application.register('sortable', SortableController)

import TabController from './controllers/tab_controller'
application.register('tab', TabController)

import TagSelectorController from './controllers/tag_selector_controller'
application.register('tag-selector', TagSelectorController)

// clean snackbar content
document.addEventListener('turbo:before-cache', () => {
  document.getElementById('snackbar-container').innerHTML = ''
})
