import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {

    setTimeout(() => {
      this.element.classList.remove('-translate-y-full', 'opacity-0')
    }, 100)

    setTimeout(() => {
      this.element.classList.add('-translate-y-full', 'opacity-0')
    }, 3000)
  }
}