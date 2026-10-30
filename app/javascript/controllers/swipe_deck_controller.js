import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Swipes the cards of the deck. `position` is the card on screen, from 1.
// Each decision hides the current card, shows the next one and records the
// swipe; the server answers with a Turbo Stream that redraws the progress.
export default class extends Controller {
  static targets = [ "slot" ]
  static values = {
    url: String,
    total: Number,
    position: { type: Number, default: 1 }
  }

  like() {
    this.decide(true)
  }

  pass() {
    this.decide(false)
  }

  decide(liked) {
    const slot = this.currentSlot
    if (!slot) return

    this.positionValue += 1
    slot.hidden = true
    this.showCurrentSlot()
    this.record(slot.dataset.animeId, liked)
  }

  showCurrentSlot() {
    const slot = this.currentSlot
    if (slot) slot.hidden = false
  }

  async record(animeId, liked) {
    const response = await fetch(this.urlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": this.csrfToken, "Accept": "text/vnd.turbo-stream.html" },
      body: new URLSearchParams({
        anime_id: animeId,
        liked: liked,
        position: this.positionValue,
        total: this.totalValue
      })
    })

    if (response.ok) Turbo.renderStreamMessage(await response.text())
  }

  get currentSlot() {
    return this.slotTargets[this.positionValue - 1]
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }
}
