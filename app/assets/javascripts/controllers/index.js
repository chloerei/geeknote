import { Application } from "@hotwired/stimulus"

const application = Application.start()

import SelectorController from './selector_controller'
application.register('selector', SelectorController)

import CollectionItemController from './collection_item_controller'
application.register('collection-item', CollectionItemController)

import DraggableController from './draggable_controller'
application.register('draggable', DraggableController)

import FieldsetManagerController from './fieldset_manager_controller'
application.register('fieldset-manager', FieldsetManagerController)

import FormController from './form_controller'
application.register('form', FormController)

import PageNavController from './page_nav_controller'
application.register('page-nav', PageNavController)

import PaginationController from './pagination_controller'
application.register('pagination', PaginationController)

import PostListController from './post_list_controller'
application.register('post-list', PostListController)

import PostFormController from './post_form_controller'
application.register('post-form', PostFormController)

import RevisionController from './revision_controller'
application.register('revision', RevisionController)

import SortableController from './sortable_controller'
application.register('sortable', SortableController)

import TagSelectorController from './tag_selector_controller'
application.register('tag-selector', TagSelectorController)

import ThemeSettingsController from './theme_settings_controller'
application.register('theme-settings', ThemeSettingsController)

import ImageUploaderController from './image_uploader_controller'
application.register('image-uploader', ImageUploaderController)

import MarkdownEditorController from './markdown_editor_controller'
application.register('markdown-editor', MarkdownEditorController)

import CommentController from './comment_controller'
application.register('comment', CommentController)

import SnackbarController from './snackbar_controller'
application.register('snackbar', SnackbarController)

import TextFieldController from './text_field_controller'
application.register('text-field', TextFieldController)

import RecaptchaController from './recaptcha_controller'
application.register('recaptcha', RecaptchaController)

import AutoGrowController from './auto_grow_controller'
application.register('auto-grow', AutoGrowController)

import TocController from './toc_controller'
application.register('toc', TocController)

import RemovableController from './removable_controller'
application.register('removable', RemovableController)
