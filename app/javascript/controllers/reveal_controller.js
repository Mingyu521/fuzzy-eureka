import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value", "toggle"]
  static values = { revealed: Boolean, real: String, masked: String }

  connect() {
    this.render()
  }

  toggle() {
    this.revealedValue = !this.revealedValue
  }

  revealedValueChanged() {
    this.render()
  }

  render() {
    this.valueTarget.textContent = this.revealedValue ? this.realValue : this.maskedValue
    this.toggleTarget.textContent = this.revealedValue ? "Hide" : "Reveal"
  }
}
