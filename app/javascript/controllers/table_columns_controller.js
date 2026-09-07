import { Controller } from "@hotwired/stimulus"

// Show/hide table columns. Choices are remembered per browser, and re-applied
// when Turbo swaps a row after an inline edit.
export default class extends Controller {
  static targets = ["checkbox", "count"]
  static values = { storageKey: String }

  connect() {
    // Scoped to the rows only: observing the whole controller element would
    // pick up this controller's own DOM writes and loop forever.
    this.observer = new MutationObserver(() => this.apply())

    this.hidden = new Set(this.storedKeys)
    this.syncCheckboxes()
    this.apply()
  }

  disconnect() {
    this.observer?.disconnect()
  }

  toggle(event) {
    const key = event.target.dataset.columnKey
    if (!key) return

    if (event.target.checked) {
      this.hidden.delete(key)
    } else {
      this.hidden.add(key)
    }

    this.persist()
    this.apply()
  }

  showAll() {
    this.hidden.clear()
    this.persist()
    this.syncCheckboxes()
    this.apply()
  }

  apply() {
    this.observer?.disconnect()

    this.element.querySelectorAll("table [data-column]").forEach((cell) => {
      cell.classList.toggle("hidden", this.hidden.has(cell.dataset.column))
    })
    this.updateCount()

    this.observeRows()
  }

  updateCount() {
    if (!this.hasCountTarget) return

    const label = this.hidden.size === 0 ? "All" : `${this.hidden.size} hidden`
    if (this.countTarget.textContent !== label) {
      this.countTarget.textContent = label
    }
  }

  observeRows() {
    const rows = this.element.querySelector("tbody")
    if (rows) this.observer?.observe(rows, { childList: true })
  }

  syncCheckboxes() {
    this.checkboxTargets.forEach((box) => {
      box.checked = !this.hidden.has(box.dataset.columnKey)
    })
  }

  persist() {
    try {
      localStorage.setItem(this.storageKeyValue, JSON.stringify([...this.hidden]))
    } catch (_error) {
      // Private browsing / storage disabled — selection just won't persist
    }
  }

  get storedKeys() {
    try {
      const raw = localStorage.getItem(this.storageKeyValue)
      return raw ? JSON.parse(raw) : []
    } catch (_error) {
      return []
    }
  }
}
