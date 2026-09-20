import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submitDebounced() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.element.requestSubmit(), 300)
  }

  submitNow() {
    this.element.requestSubmit()
  }
}
