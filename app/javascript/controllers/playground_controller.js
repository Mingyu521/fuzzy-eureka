import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { apiKey: String }
  static targets = ["channel", "title", "description", "icon", "tags", "preview", "result"]

  connect() {
    this.updatePreview()
  }

  updatePreview() {
    this.preview.textContent = this.buildSnippet()
  }

  buildSnippet() {
    const body = this.buildBody()
    return [
      `fetch("${window.location.origin}/api/events", {`,
      `  method: "POST",`,
      `  headers: {`,
      `    "Content-Type": "application/json",`,
      `    "Authorization": "Bearer ${this.apiKeyValue}"`,
      `  },`,
      `  body: JSON.stringify(${JSON.stringify(body, null, 2).split("\n").join("\n  ")})`,
      `})`
    ].join("\n")
  }

  buildBody() {
    const body = {
      channel: this.channelTarget.value || "orders",
      title: this.titleTarget.value || "New Order"
    }
    if (this.descriptionTarget.value) body.description = this.descriptionTarget.value
    if (this.iconTarget.value) body.icon = this.iconTarget.value

    const rawTags = this.tagsTarget.value.trim()
    if (rawTags) {
      try {
        body.tags = JSON.parse(rawTags)
      } catch (e) {
        body.tags = {}
      }
    }
    return body
  }

  get preview() {
    return this.previewTarget
  }

  async send(event) {
    event.preventDefault()
    const body = this.buildBody()

    this.resultTarget.hidden = false
    this.resultTarget.textContent = "Sending..."

    try {
      const response = await fetch("/api/events", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${this.apiKeyValue}`
        },
        body: JSON.stringify(body)
      })
      const json = await response.json()
      this.resultTarget.textContent = `${response.status} ${response.ok ? "OK" : "ERROR"}\n${JSON.stringify(json, null, 2)}`
    } catch (error) {
      this.resultTarget.textContent = `Request failed: ${error}`
    }
  }
}
