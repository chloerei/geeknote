import { MarkdownMirror } from "./mirror"
import { DirectUpload } from "@rails/activestorage"
import { post } from '@rails/request.js'

const acceptFileTypes = [
  'image/png',
  'image/gif',
  'image/jpeg',
  'image/svg+xml',
  'video/mp4',
  'video/quicktime',
  'video/webm'
]

const acceptFileSize = 10 * 1024 * 1024

class MarkdownEditor extends HTMLElement {
  static observedAttributes = ["input"]

  constructor() {
    super()

    this.suggestionRoundKey = null
    this.suggestionSeq = 0
  }

  connectedCallback() {
    const inputElement = document.getElementById(this.getAttribute("input"))

    this.editElement = document.createElement("div")
    this.editElement.classList.add("edit")
    this.appendChild(this.editElement)

    this.previewElement = document.createElement("div")
    this.previewElement.classList.add("preview", "typography")
    this.previewElement.style.display = "none"
    this.appendChild(this.previewElement)

    this.markdownMirror = new MarkdownMirror({
      parent: this.editElement,
      input: inputElement,
      scrollMargin: { top: 0, bottom: 100 },
      onFileAccept: (file) => {
        return acceptFileTypes.includes(file.type) && file.size <= acceptFileSize
      },
      onFileAttach: (file, successCallback) => {
        const upload = new DirectUpload(file, "/rails/active_storage/direct_uploads")
        upload.create(async (error, blob) => {
          if (error) {
            console.error(error)
          } else {
            let formData = new FormData()
            formData.append('attachment[file]', blob.signed_id)
            const response = await post('/attachments', {
                body: formData
              }
            )
            if (response.ok) {
              const data = await response.json
              successCallback({ name: data.filename, url: data.url })
            }
          }
        })
      },
      onSuggestionsChange: () => {
        this.syncSuggestionsUi()
      }
    })
  }

  disconnectedCallback() {
    this.suggestionRoundKey = null

    this.markdownMirror.destroy()
    this.markdownMirror = null
    this.editElement.remove()
    this.previewElement.remove()
  }

  focus() {
    this.markdownMirror.focus()
  }

  attachFile(file) {
    this.markdownMirror.attachFile(file)
  }

  async preview() {
    this.classList.add("fetching")

    const formData = new FormData()
    formData.append("content", this.markdownMirror.getContent())
    const response = await post("/preview", {
      body: formData
    })

    if (response.ok) {
      this.classList.remove("fetching")

      this.editElement.style.display = "none"
      this.previewElement.style.display = "block"

      const html = await response.html

      this.previewElement.innerHTML = html
    }
  }

  edit() {
    this.editElement.style.display = "flex"
    this.previewElement.style.display = "none"
    this.previewElement.innerHTML = ""
  }

  // --- AI suggestions ---------------------------------------------------
  //
  // Suggestions are transient client-side state: they live only while the
  // conversation round is open. Content blocks arrive through the ai_suggestion
  // turbo stream action and render inside the editor as inline diff hunks with
  // an accept/reject chip. Title changes apply immediately to the title input.
  // The chat panel exposes accept-all / reject-all, which just call the methods
  // below.

  showAiSuggestion({ roundId = null, blocks = [] } = {}) {
    if (!this.markdownMirror) return
    if (!Array.isArray(blocks) || blocks.length === 0) return

    const roundKey = roundId || null
    // Blocks from a newer round supersede everything pending from an older one.
    if (this.suggestionRoundKey !== null && roundKey !== null && this.suggestionRoundKey !== roundKey) {
      this.rejectAllSuggestions()
    }
    this.suggestionRoundKey = roundKey

    for (const raw of blocks) {
      if (raw.type === "rewrite") {
        // A whole-document rewrite conflicts with pending localized edits.
        this.markdownMirror.clearContentSuggestions()
        this.markdownMirror.appendSuggestionBlock({
          id: ++this.suggestionSeq,
          type: "rewrite",
          newText: raw.new_text ?? ""
        })
      } else if (raw.type === "replace") {
        if (this.markdownMirror.hasRewritePending) continue
        this.markdownMirror.appendSuggestionBlock({
          id: ++this.suggestionSeq,
          type: "replace",
          oldText: raw.old_text ?? "",
          newText: raw.new_text ?? ""
        })
      } else if (raw.type === "title") {
        this.applyTitleSuggestion(raw.new_title)
      }
    }

    this.syncSuggestionsUi()
  }

  // Title changes are applied directly, without user review.
  applyTitleSuggestion(newTitle) {
    if (!newTitle) return

    const input = document.getElementById("post_title")
    if (!input || input.value === newTitle) return

    input.value = newTitle
    input.dispatchEvent(new Event("input", { bubbles: true }))
  }

  acceptAllSuggestions() {
    this.markdownMirror?.acceptAllSuggestions()
    this.syncSuggestionsUi()
  }

  rejectAllSuggestions() {
    this.markdownMirror?.rejectAllSuggestions()
    this.syncSuggestionsUi()
  }

  suggestionCount() {
    return this.markdownMirror?.pendingContentCount ?? 0
  }

  syncSuggestionsUi() {
    document.dispatchEvent(new CustomEvent("ai-suggestions:changed", {
      detail: { count: this.suggestionCount() }
    }))
  }
}

customElements.define("markdown-editor", MarkdownEditor)
