import { Controller } from "@hotwired/stimulus"

// Lightweight Radix-style dropdown: Escape closes, outside click closes, aria-expanded sync.
export default class extends Controller {
  static targets = ["trigger", "content"]
  static values = { open: { type: Boolean, default: false } }

  connect() {
    this._onKey = this.onKeydown.bind(this)
    this._onDoc = this.onDocumentClick.bind(this)
  }

  disconnect() {
    this.teardown()
  }

  toggle(event) {
    event.preventDefault()
    this.openValue = !this.openValue
  }

  openValueChanged() {
    if (this.openValue) {
      this.contentTarget.classList.remove("hidden")
      this.triggerTarget.setAttribute("aria-expanded", "true")
      document.addEventListener("keydown", this._onKey)
      document.addEventListener("click", this._onDoc)
    } else {
      this.contentTarget.classList.add("hidden")
      this.triggerTarget.setAttribute("aria-expanded", "false")
      this.teardown()
    }
  }

  onKeydown(event) {
    if (event.key === "Escape") this.openValue = false
  }

  onDocumentClick(event) {
    if (!this.element.contains(event.target)) this.openValue = false
  }

  teardown() {
    document.removeEventListener("keydown", this._onKey)
    document.removeEventListener("click", this._onDoc)
  }
}
