import { Turbo } from "@hotwired/turbo-rails"

// Update the post title when the AI changes the snapshot title via the change_title tool
Turbo.StreamActions.change_title = function () {
  const title = this.getAttribute("title")
  if (title === null) return

  const titleInput = document.getElementById("post_title")
  if (titleInput) titleInput.value = title
}
