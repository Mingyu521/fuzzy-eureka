import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

Chart.register(...registerables)

const PALETTE = ["#01fdf6", "#ff10f0", "#faed27", "#bc13fe", "#0aff9d", "#ff9f1c"]

function channelColor(name) {
  let sum = 0
  for (let i = 0; i < name.length; i++) sum += name.charCodeAt(i)
  return PALETTE[sum % PALETTE.length]
}

export default class extends Controller {
  static values = { project: String }
  static targets = ["daily", "doughnut", "perChannel"]

  async connect() {
    const response = await fetch(`/api/charts?project=${this.projectValue}`)
    const data = await response.json()

    if (this.hasDailyTarget) this.renderDaily(data.daily)
    if (this.hasDoughnutTarget) this.renderDoughnut(data.by_channel)
    if (this.hasPerChannelTarget) this.renderPerChannel(data.by_channel_daily)
  }

  renderDaily(daily) {
    new Chart(this.dailyTarget, {
      type: "line",
      data: {
        labels: daily.map((d) => d.date),
        datasets: [
          {
            label: "Events per day",
            data: daily.map((d) => d.count),
            borderColor: "#01fdf6",
            backgroundColor: "rgba(1,253,246,0.15)",
            fill: true,
            tension: 0.3,
            pointBackgroundColor: "#ff10f0",
            pointBorderColor: "#ff10f0"
          }
        ]
      },
      options: this.baseOptions()
    })
  }

  renderDoughnut(byChannel) {
    new Chart(this.doughnutTarget, {
      type: "doughnut",
      data: {
        labels: byChannel.map((c) => c.channel),
        datasets: [
          {
            data: byChannel.map((c) => c.count),
            backgroundColor: byChannel.map((c) => channelColor(c.channel)),
            borderColor: "#0d0221",
            borderWidth: 2
          }
        ]
      },
      options: {
        plugins: {
          legend: { labels: { color: "#eee6ff", font: { family: "Space Mono" } } }
        }
      }
    })
  }

  renderPerChannel(byChannelDaily) {
    const container = this.perChannelTarget
    container.innerHTML = ""

    Object.entries(byChannelDaily || {}).forEach(([channel, points]) => {
      const wrapper = document.createElement("div")
      wrapper.className = "card"
      wrapper.style.marginBottom = "16px"

      const title = document.createElement("div")
      title.style.cssText = `font-family: var(--font-display); font-size: 13px; margin-bottom: 10px; color: ${channelColor(channel)}`
      title.textContent = channel

      const canvas = document.createElement("canvas")
      canvas.className = "chart-canvas"

      wrapper.appendChild(title)
      wrapper.appendChild(canvas)
      container.appendChild(wrapper)

      new Chart(canvas, {
        type: "bar",
        data: {
          labels: points.map((p) => p.date),
          datasets: [
            {
              label: channel,
              data: points.map((p) => p.count),
              backgroundColor: channelColor(channel)
            }
          ]
        },
        options: this.baseOptions()
      })
    })
  }

  baseOptions() {
    return {
      scales: {
        x: { ticks: { color: "#a996d1" }, grid: { color: "rgba(255,255,255,0.06)" } },
        y: { ticks: { color: "#a996d1" }, grid: { color: "rgba(255,255,255,0.06)" }, beginAtZero: true }
      },
      plugins: { legend: { display: false } }
    }
  }
}
