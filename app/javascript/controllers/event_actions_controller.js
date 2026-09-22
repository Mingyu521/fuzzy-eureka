import { Controller } from "@hotwired/stimulus"

// Favorite/delete just hit the JSON API; the resulting DB change broadcasts
// back over Action Cable and updates every open tab, this one included.
export default class extends Controller {
  static values = { id: Number, apiKey: String }

  favorite() {
    fetch(`/api/events/${this.idValue}/favorite`, { method: "POST", headers: this.headers() })
  }

  destroy() {
    if (!confirm("Delete this event?")) return
    fetch(`/api/events/${this.idValue}/delete`, { method: "POST", headers: this.headers() })
  }

  headers() {
    return { Authorization: `Bearer ${this.apiKeyValue}` }
  }
}
