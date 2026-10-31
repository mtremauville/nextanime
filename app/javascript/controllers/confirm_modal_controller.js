import { Controller } from "@hotwired/stimulus"

// Opens and closes a confirmation modal, a native <dialog>.
// The dialog traps the focus and closes on Escape by itself.
export default class extends Controller {
  static targets = [ "dialog" ]

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
}
