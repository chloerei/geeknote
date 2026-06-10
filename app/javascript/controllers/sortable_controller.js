import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";
import { patch } from "@rails/request.js";

// Connects to data-controller="sortable"
export default class extends Controller {
  static values = {
    handle: String,
    resourceName: String,
    paramName: { type: String, default: "position" },
  };

  connect() {
    this.sortable = new Sortable(this.element, {
      handle: this.handleValue,
      onUpdate: (event) => this.onUpdate(event),
    });
  }

  onUpdate(event) {
    const item = event.item;
    const updateUrl = item.dataset.sortableUpdateUrl;

    if (!updateUrl) return;

    const position = event.newIndex + 1;

    const formData = new FormData();
    if (this.hasResourceNameValue) {
      formData.append(`${this.resourceNameValue}[position]`, position);
    } else {
      formData.append("position", position);
    }

    patch(updateUrl, { body: formData });
  }
}
