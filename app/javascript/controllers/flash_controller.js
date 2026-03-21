import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  dismiss() {
    this.element.remove()
  }

  connect() {
    setTimeout(() => {
      this.element.style.transition = "opacity 0.3s"
      this.element.style.opacity = "0"
      setTimeout(() => this.element.remove(), 300)
    }, 5000)
  }
}
