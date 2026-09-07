import { Controller } from "@hotwired/stimulus"

const SVG_NS = "http://www.w3.org/2000/svg"

// Draws the reporting arrows between org chart nodes. Positions are measured
// from the rendered DOM, so the lines follow whatever the layout does.
export default class extends Controller {
  static targets = ["canvas", "edges"]

  connect() {
    this.activeKey = null
    this.lastSize = null

    this.resizeObserver = new ResizeObserver(this.onResize)
    this.resizeObserver.observe(this.element)
    window.addEventListener("resize", this.scheduleDraw)
    document.fonts?.ready.then(this.scheduleDraw)

    this.element.addEventListener("pointerover", this.onPointerOver)
    this.element.addEventListener("pointerleave", this.onPointerLeave)

    this.scheduleDraw()
  }

  disconnect() {
    this.resizeObserver?.disconnect()
    window.removeEventListener("resize", this.scheduleDraw)
    this.element.removeEventListener("pointerover", this.onPointerOver)
    this.element.removeEventListener("pointerleave", this.onPointerLeave)
    if (this.frame) cancelAnimationFrame(this.frame)
  }

  // Coalesce bursts of resize notifications into one draw per frame
  scheduleDraw = () => {
    if (this.frame) return

    this.frame = requestAnimationFrame(() => {
      this.frame = null
      this.draw()
    })
  }

  // Drawing adds nodes inside the observed element, so only react to a real
  // size change — otherwise the observer could feed itself.
  onResize = () => {
    const { width, height } = this.element.getBoundingClientRect()
    const size = `${Math.round(width)}x${Math.round(height)}`
    if (size === this.lastSize) return

    this.lastSize = size
    this.scheduleDraw()
  }

  toggleBranch(event) {
    const button = event.currentTarget
    const body = this.element.querySelector(`[data-branch-body="${CSS.escape(button.dataset.branch)}"]`)
    if (!body) return

    const collapsed = body.classList.toggle("hidden")
    button.setAttribute("aria-expanded", String(!collapsed))
    button.classList.toggle("-rotate-90", collapsed)
    button.title = collapsed ? "Expand team" : "Collapse team"
    this.draw()
  }

  draw() {
    if (!this.hasCanvasTarget) return

    const box = this.element.getBoundingClientRect()
    this.lastSize = `${Math.round(box.width)}x${Math.round(box.height)}`
    this.canvasTarget.setAttribute("viewBox", `0 0 ${box.width} ${box.height}`)
    this.edgesTarget.replaceChildren()

    this.element.querySelectorAll("[data-org-node][data-org-parent]").forEach((child) => {
      const parentKey = child.dataset.orgParent
      if (!parentKey) return

      const parent = this.element.querySelector(`[data-org-node="${CSS.escape(parentKey)}"]`)
      if (!parent || this.isHidden(parent) || this.isHidden(child)) return

      this.edgesTarget.appendChild(this.buildEdge(parent, child, box))
    })

    this.applyHighlight()
  }

  buildEdge(parent, child, box) {
    const p = this.relativeRect(parent, box)
    const c = this.relativeRect(child, box)
    const startX = p.x + p.width / 2
    const startY = p.y + p.height

    let d
    if (c.x > startX + 12) {
      // Child hangs off to the side: down the trunk, then in from the left
      d = `M ${startX} ${startY} V ${c.y + c.height / 2} H ${c.x - 9}`
    } else {
      // Child sits below: down, across, then into the top edge
      const midY = startY + Math.max((c.y - startY) / 2, 14)
      d = `M ${startX} ${startY} V ${midY} H ${c.x + c.width / 2} V ${c.y - 9}`
    }

    const path = document.createElementNS(SVG_NS, "path")
    path.setAttribute("d", d)
    path.setAttribute("marker-end", "url(#org-arrow)")
    path.setAttribute("stroke-linejoin", "round")
    path.dataset.from = parent.dataset.orgNode
    path.dataset.to = child.dataset.orgNode
    return path
  }

  onPointerOver = (event) => {
    const key = event.target.closest("[data-org-node]")?.dataset.orgNode || null
    if (key === this.activeKey) return

    this.activeKey = key
    this.applyHighlight()
  }

  onPointerLeave = () => {
    this.activeKey = null
    this.applyHighlight()
  }

  // Emphasise the lines into and out of the person being hovered
  applyHighlight() {
    this.edgesTarget.querySelectorAll("path").forEach((path) => {
      const related = this.activeKey && (path.dataset.from === this.activeKey || path.dataset.to === this.activeKey)
      path.setAttribute("stroke", related ? "#287968" : "#c9d5cd")
      path.setAttribute("stroke-width", related ? "2" : "1.5")
      path.setAttribute("marker-end", related ? "url(#org-arrow-active)" : "url(#org-arrow)")
    })
  }

  relativeRect(element, box) {
    const rect = element.getBoundingClientRect()
    return { x: rect.left - box.left, y: rect.top - box.top, width: rect.width, height: rect.height }
  }

  isHidden(element) {
    return element.offsetParent === null
  }
}
