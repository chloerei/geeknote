export function debounce(func, wait) {
  let timeout
  return function executedFunction(...args) {
    const context = this
    const later = function () {
      timeout = null
      func.apply(context, args)
    };
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}

export function throttle(func, limit) {
  let lastFunc
  let lastRan
  return function executedFunction(...args) {
    const context = this
    if (!lastRan) {
      func.apply(context, args)
      lastRan = Date.now()
    } else {
      clearTimeout(lastFunc)
      lastFunc = setTimeout(function () {
        if ((Date.now() - lastRan) >= limit) {
          func.apply(context, args)
          lastRan = Date.now()
        }
      }, limit - (Date.now() - lastRan))
    }
  }
}
