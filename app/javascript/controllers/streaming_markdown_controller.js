import { Controller } from "@hotwired/stimulus"
import { marked } from "marked"
import DOMPurify from "dompurify"

// Debounce (ms) between a raw-content mutation and a re-render of the whole
// markdown. LLM streams arrive as many small chunks, and markdown can only be
// parsed as a whole document, so we coalesce bursts into one render pass.
const RENDER_DELAY = 50

// Connects to data-controller="streaming-markdown"
//
// Keeps the original markdown text in a "raw" target that the server keeps
// appending streamed chunks to, and renders the full text as sanitized HTML
// into a sibling "rendered" target. Re-rendering the whole document on every
// mutation is what makes cross-chunk syntax (code fences, bold, tables) come
// out right mid-stream.
export default class extends Controller {
  static targets = [ "raw", "rendered" ]

  connect() {
    this.observer = new MutationObserver(() => this.scheduleRender())
    this.observer.observe(this.rawTarget, { childList: true, characterData: true, subtree: true })
    this.render()
  }

  disconnect() {
    this.observer?.disconnect()
    if (this.renderTimer) clearTimeout(this.renderTimer)
  }

  scheduleRender() {
    if (this.renderTimer) return
    this.renderTimer = setTimeout(() => {
      this.renderTimer = null
      this.render()
    }, RENDER_DELAY)
  }

  render() {
    const text = this.rawTarget.textContent ?? ""
    const html =
      text.length > 0
        ? DOMPurify.sanitize(marked.parse(text, { gfm: true, breaks: true }))
        : ""
    this.renderedTarget.innerHTML = html
  }
}
