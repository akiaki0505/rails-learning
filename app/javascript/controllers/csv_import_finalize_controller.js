import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "loading", "results", "message", "errorList"]

  async submit(event) {
    event.preventDefault()

    this.resultsTarget.classList.add("hidden")
    this.loadingTarget.classList.remove("hidden")

    const formData = new FormData(this.formTarget)
    
    try {
      const response = await fetch(this.formTarget.action, {
        method: "POST",
        body: formData,
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        }
      })

      const data = await response.json()

      if (response.ok) {
        window.location.href = data.location
      } else {
        this.loadingTarget.classList.add("hidden")
        this.showErrors(data)
      }
    } catch (error) {
      console.error(error)
      this.loadingTarget.classList.add("hidden")
      this.showErrors({ alert: "A network error occurred." })
    }
  }

  showErrors(data) {
    this.messageTarget.innerText = data.alert || "Import failed:"
    this.errorListTarget.innerHTML = ""

    if (data.errors) {
      data.errors.forEach(err => {
        const li = document.createElement("li")
        li.innerText = err
        this.errorListTarget.appendChild(li)
      })
    }

    this.resultsTarget.classList.remove("hidden")
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
}