import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    updateUrl: String
  }

  dragStart(event) {
    const card = event.currentTarget
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", card.dataset.itemId)
    card.classList.add("opacity-50")
  }

  dragEnd(event) {
    event.currentTarget.classList.remove("opacity-50")
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    event.currentTarget.classList.add("ring-2", "ring-accent-300")
  }

  dragLeave(event) {
    event.currentTarget.classList.remove("ring-2", "ring-accent-300")
  }

  async drop(event) {
    event.preventDefault()
    const column = event.currentTarget
    column.classList.remove("ring-2", "ring-accent-300")

    const itemId = event.dataTransfer.getData("text/plain")
    const status = column.dataset.status
    if (!itemId || !status) return

    const card = this.element.querySelector(`[data-item-id="${itemId}"]`)
    const list = column.querySelector("[data-kanban-list]")
    if (card && list) {
      list.appendChild(card)
    }

    const siblings = list ? Array.from(list.children) : []
    const position = siblings.findIndex((el) => el.dataset.itemId === itemId)

    const csrf = document.querySelector("meta[name='csrf-token']")?.content
    const url = `/action_items/${itemId}/update_status`

    try {
      await fetch(url, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": csrf
        },
        body: JSON.stringify({ status, position: Math.max(position, 0) })
      })
    } catch (_error) {
      // Keep optimistic UI; user can refresh if needed
    }
  }
}
