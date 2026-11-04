import { Controller } from "@hotwired/stimulus"

// Sends a form as soon as one of its fields changes, so that filtering needs no button.
// The submit button stays in the page for visitors without JavaScript;
// it is hidden once this controller runs.
export default class extends Controller {
  static targets = [ "submit" ]

  connect() {
    this.submitTargets.forEach((button) => { button.hidden = true })
  }

  submit() {
    this.element.requestSubmit()
  }
}
