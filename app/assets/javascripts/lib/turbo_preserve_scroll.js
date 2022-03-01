let scrollTop = 0

window.addEventListener("turbo:click", ({ target }) => {
  if (target.hasAttribute("data-turbo-preserve-scroll")) {
    scrollTop = document.scrollingElement.scrollTop
  }
})

window.addEventListener("turbo:render", () => {
  if (scrollTop) {
    document.scrollingElement.scrollTo(0, scrollTop)
    Turbo.navigator.currentVisit.scrolled = true
  }

  scrollTop = 0
})
