import { Controller } from "@hotwired/stimulus"

const SAFETY_DELAY_MS = 10000

// Marque son élément comme occupé pendant une requête, pour que le style
// affiche un spinner. Sur succès, Turbo remplace le bloc : l'élément disparaît.
export default class extends Controller {
  start() {
    this.element.setAttribute("aria-busy", "true")
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.stop(), SAFETY_DELAY_MS)
  }

  stop() {
    clearTimeout(this.timer)
    this.element.removeAttribute("aria-busy")
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
