import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "nextanime-theme"
const DARK = "dark"
const LIGHT = "light"
const DEFAULT_THEME = DARK

export default class extends Controller {
  connect() {
    this.#apply(this.#read() || DEFAULT_THEME)
    this.element.dataset.themeReady = "true"
  }

  toggle() {
    this.#apply(document.documentElement.dataset.bsTheme === DARK ? LIGHT : DARK)
  }

  #apply(theme) {
    document.documentElement.dataset.bsTheme = theme
    this.#syncSwitches(theme)
    try { localStorage.setItem(STORAGE_KEY, theme) } catch (_) { /* storage unavailable */ }
  }

  // Keeps every theme switch in sync, wherever the theme was changed from. A switch is on in the dark theme.
  #syncSwitches(theme) {
    document.querySelectorAll("[role='switch'][data-controller~='theme']").forEach((themeSwitch) => {
      themeSwitch.setAttribute("aria-checked", String(theme === DARK))
    })
  }

  #read() {
    try { return localStorage.getItem(STORAGE_KEY) } catch (_) { return null }
  }
}
