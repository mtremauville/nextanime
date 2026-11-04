import { Controller } from "@hotwired/stimulus"

// Sends a form as soon as one of its fields changes, so that filtering needs no button.
// Visitors without JavaScript keep the submit button: the style hides it for everyone else.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
