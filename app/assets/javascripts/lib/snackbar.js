export class Snackbar {
  static display(text, period = 5000) {
    let container = document.querySelector('#snackbar-container')
    if (container) {
      let snackbar = document.createElement('div')
      snackbar.className = 'snackbar'
      snackbar.textContent = text
      snackbar.dataset.controller = 'snackbar'
      snackbar.dataset.snackbarPeriod = period
      container.innerHTML = ''
      container.appendChild(snackbar)
    }
  }
}
