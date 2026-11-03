import { Controller } from "@hotwired/stimulus"

// Opens and closes a confirmation modal, a native <dialog>.
// The dialog traps the focus and closes on Escape by itself.
// When a word has to be typed, the confirmation stays disabled until it matches.
export default class extends Controller {
  static targets = [ "dialog", "word", "confirm" ]
  static values = { word: String }

  open() {
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  // The padding lives on the inner panel, so only a click on the backdrop targets the dialog.
  backdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  check() {
    const matches = this.wordTarget.value === this.wordValue
    this.confirmTarget.disabled = !matches
    this.confirmTarget.setAttribute("aria-disabled", String(!matches))
  }
}
