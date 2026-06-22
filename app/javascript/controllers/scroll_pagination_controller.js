import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";

// Connects to data-controller="scroll-pagination"
export default class extends Controller {
  static targets = ["content", "next", "nextLink"];

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
    const response = await get(this.nextLinkTarget.href);
    if (response.ok) {
      const html = await response.html;
      const dom = new DOMParser().parseFromString(html, "text/html");
      this.contentTarget.insertAdjacentHTML(
        "beforeend",
        dom.getElementById(this.contentTarget.id).innerHTML,
      );
      this.nextTarget.innerHTML = dom.getElementById(
        this.nextTarget.id,
      ).innerHTML;
      if (this.observer && this.hasNextLinkTarget) {
        this.observer.observe(this.nextLinkTarget);
      }
    }
  }

  load(event) {
    event.preventDefault();
    this.loadNextPage();
  }
}
