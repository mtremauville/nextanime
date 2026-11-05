import { Controller } from "@hotwired/stimulus"

// Opens and closes a bottom sheet, a native <dialog>.
// The dialog traps the focus, closes on Escape and gives the focus back by itself.
export default class extends Controller {
  static targets = [ "dialog" ]

  open() {
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  // The panel fills the dialog, so only a click on the backdrop targets the dialog itself.
  backdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }
}
