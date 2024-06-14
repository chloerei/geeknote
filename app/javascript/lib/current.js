class Current {
  static attributes = {}

  static get user() {
    if (!this.attributes.user) {
      if (document.querySelector('meta[name="current-user-id"]')) {
        this.attributes.user = {
          id: parseInt(document.querySelector('meta[name="current-user-id"]').content),
        }
      }
    }
    return this.attributes.user
  }

  static reset() {
    this.attributes = {}
  }
}

document.addEventListener('turbo:load', () => {
  Current.reset()
})

export { Current }
