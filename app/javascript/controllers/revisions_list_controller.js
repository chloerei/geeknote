import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="revisions-list"
export default class extends Controller {
  connect() {
    this.mainFrame = document.querySelector('turbo-frame[id="revisions-main"]');
    if (!this.mainFrame) return;

    this.mainFrame.addEventListener("turbo:frame-load", this.onFrameLoad);

    // Re-sync highlight when scroll pagination appends more items
    this.observer = new MutationObserver(this.syncState);
    this.observer.observe(this.element, { childList: true, subtree: true });

    this.syncState();
  }

  disconnect() {
    if (this.mainFrame) {
      this.mainFrame.removeEventListener("turbo:frame-load", this.onFrameLoad);
    }
    if (this.observer) {
      this.observer.disconnect();
    }
  }

  onFrameLoad = () => {
    this.syncState();

    // Scroll content to top and close the mobile drawer
    window.scrollTo(0, 0);
    const toggle = document.getElementById("revisions-drawer-toggle");
    if (toggle) {
      toggle.checked = false;
    }
  };

  syncState = () => {
    const meta = this.mainFrame.querySelector("[data-revision-id]");
    if (!meta) return;

    const revisionId = meta.dataset.revisionId;
    this.element.querySelectorAll("[data-revision-id]").forEach((item) => {
      item.classList.toggle(
        "bg-primary/10",
        String(item.dataset.revisionId) === String(revisionId),
      );
    });
  };
}
