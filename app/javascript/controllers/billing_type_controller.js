import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "fixedAmount"]

  connect() {
    this.toggle()
  }

  toggle() {
    if (!this.hasFixedAmountTarget || !this.hasSelectTarget) return
    const isFixed = this.selectTarget.value === "fixed_price"
    this.fixedAmountTarget.classList.toggle("hidden", !isFixed)
  }
}
