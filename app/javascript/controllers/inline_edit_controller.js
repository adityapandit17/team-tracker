import { Controller } from "@hotwired/stimulus"

// Set when a cell is saved while still focused (select, date, checkbox, Enter),
// so the replacement row can hand focus back to the same cell.
let pendingFocus = null

export default class extends Controller {
  static targets = ["input"]

  connect() {
    if (pendingFocus !== this.cellKey) return

    pendingFocus = null
    this.inputTarget.focus()
    if (this.inputTarget.type === "text") {
      const end = this.inputTarget.value.length
      this.inputTarget.setSelectionRange(end, end)
    }
  }

  submit() {
    // A text cell saved on blur means the user already moved on — don't pull focus back.
    if (document.activeElement === this.inputTarget) {
      pendingFocus = this.cellKey
    }

    this.inputTarget.classList.add("opacity-50")
    this.element.requestSubmit()
  }

  // Enter commits a text cell without waiting for blur
  commit(event) {
    event.preventDefault()
    this.submit()
  }

  get cellKey() {
    return `${this.element.action}#${this.element.elements.field.value}`
  }
}
