import { Controller } from "@hotwired/stimulus"

// Narrows a list of choices to the ones that hold what is typed, without leaving the page.
// The field is hidden in the page and shown here: without the script it would do nothing.
// It has no name, so the form never sends it, and it neither sends the form on a change nor on Enter.
export default class extends Controller {
  static targets = [ "field", "input", "item", "empty" ]

  connect() {
    this.fieldTarget.hidden = false
  }

  filter() {
    const wanted = normalize(this.inputTarget.value)
    const matching = this.itemTargets.filter((item) => normalize(item.dataset.filterSearchText).includes(wanted))

    this.itemTargets.forEach((item) => { item.hidden = !matching.includes(item) })
    this.emptyTarget.textContent = matching.length > 0 ? "" : this.emptyTarget.dataset.filterSearchMessage
  }

  stop(event) {
    event.stopPropagation()
  }

  prevent(event) {
    event.preventDefault()
  }
}

// "Bébé", "bebe" and " BEBE " are the same search.
function normalize(text) {
  return text.normalize("NFD").replace(/\p{M}/gu, "").toLowerCase().trim()
}
