import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";

// Connects to data-controller="scroll-pagination"
export default class extends Controller {
  static targets = ["nextLink"];

  static values = {
    autoLoad: { type: Boolean, default: false },
  };

  connect() {
    if (this.autoLoadValue) {
      this.createObserver();
    }
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect();
    }
  }

  createObserver() {
    this.observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          this.observer.unobserve(this.nextLinkTarget);
          this.loadNextPage();
        }
      },
      {
        rootMargin: "1000px",
      },
    );

    if (this.hasNextLinkTarget) {
      this.observer.observe(this.nextLinkTarget);
    }
  }

  async loadNextPage() {
    const nextLink = this.nextLinkTarget;
    if (!nextLink) return;

    const response = await get(nextLink.href);
    if (!response.ok) return;

    const html = await response.html;
    const dom = new DOMParser().parseFromString(html, "text/html");
    // The controller element is the wrapper itself.
    const wrapper = dom.getElementById(this.element.id);
    if (!wrapper) return;

    // Replace the nextLink with the response wrapper's content
    // (new items and the next nextLink).
    nextLink.replaceWith(...wrapper.childNodes);

    if (this.observer && this.hasNextLinkTarget) {
      this.observer.observe(this.nextLinkTarget);
    }
  }

  load(event) {
    event.preventDefault();
    this.loadNextPage();
  }
}
