import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "nextanime-theme"
const DEFAULT_THEME = "dark"
const THEMES = [ "dark", "light" ]

export default class extends Controller {
  connect() {
    this.#apply(this.#read() || DEFAULT_THEME)
    this.element.dataset.themeReady = "true"
  }

  toggle() {
    this.#apply(document.documentElement.dataset.bsTheme === "dark" ? "light" : "dark")
  }

  choose({ params: { theme } }) {
    if (THEMES.includes(theme)) this.#apply(theme)
  }

  #apply(theme) {
    document.documentElement.dataset.bsTheme = theme
    this.#syncChoices(theme)
    try { localStorage.setItem(STORAGE_KEY, theme) } catch (_) { /* storage unavailable */ }
  }

  // Keeps every theme choice button in sync, wherever the theme was changed from.
  #syncChoices(theme) {
    document.querySelectorAll("[data-theme-theme-param]").forEach((button) => {
      button.setAttribute("aria-pressed", String(button.dataset.themeThemeParam === theme))
    })
  }

  #read() {
    try { return localStorage.getItem(STORAGE_KEY) } catch (_) { return null }
  }
}
