import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "nextanime-theme"
const DEFAULT_THEME = "dark"

export default class extends Controller {
  connect() {
    this.#apply(this.#read() || DEFAULT_THEME)
  }

  toggle() {
    this.#apply(document.documentElement.dataset.bsTheme === "dark" ? "light" : "dark")
  }

  #apply(theme) {
    document.documentElement.dataset.bsTheme = theme
    try { localStorage.setItem(STORAGE_KEY, theme) } catch (_) { /* storage unavailable */ }
  }

  #read() {
    try { return localStorage.getItem(STORAGE_KEY) } catch (_) { return null }
  }
}
