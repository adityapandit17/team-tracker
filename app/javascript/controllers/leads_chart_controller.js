import { Controller } from "@hotwired/stimulus"
import { Chart, DoughnutController, ArcElement, Tooltip, Legend } from "chart.js"

Chart.register(DoughnutController, ArcElement, Tooltip, Legend)

export default class extends Controller {
  static values = {
    labels: Array,
    values: Array,
    colors: Array
  }

  connect() {
    const canvas = this.element.querySelector("canvas")
    if (!canvas) return

    if (this.chart) this.chart.destroy()

    this.chart = new Chart(canvas, {
      type: "doughnut",
      data: {
        labels: this.labelsValue,
        datasets: [{
          data: this.valuesValue,
          backgroundColor: this.colorsValue,
          borderWidth: 2,
          borderColor: "#ffffff"
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: "62%",
        plugins: {
          legend: {
            position: "bottom",
            labels: {
              boxWidth: 12,
              usePointStyle: true,
              pointStyle: "circle",
              font: { size: 11, family: "Plus Jakarta Sans" }
            }
          },
          tooltip: {
            callbacks: {
              label: (ctx) => `${ctx.label}: ${ctx.raw}`
            }
          }
        }
      }
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }
}
