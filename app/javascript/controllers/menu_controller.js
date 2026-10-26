import { Controller } from "@hotwired/stimulus"

// Opens and closes the mobile menu, a native modal <dialog>.
// The dialog handles focus trapping and the Escape key by itself.
export default class extends Controller {
  static targets = [ "dialog", "opener" ]

  open() {
    this.dialogTarget.showModal()
    this.openerTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    this.dialogTarget.close()
  }

  backdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  closed() {
    this.openerTarget.setAttribute("aria-expanded", "false")
  }
}
