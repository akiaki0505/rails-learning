import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["modal", "form"]
    
    open(event) {
        const url = event.params.url
        this.formTarget.action = url
        this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }
}