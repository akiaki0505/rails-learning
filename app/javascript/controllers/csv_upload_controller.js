import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "loading", "results", "errorList", "message", "fileName"]

  updateFileName(event) {
    const input = event.target
    if (input.files && input.files[0]) {
      this.fileNameTarget.textContent = "Selected: " + input.files[0].name
    }
  }

  async submit(event) {
    event.preventDefault()

    this.loadingTarget.classList.remove("hidden")
    this.resultsTarget.classList.add("hidden")
    this.errorListTarget.innerHTML = ""
    this.messageTarget.innerText = ""

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
        this.messageTarget.innerText = data.notice
        this.messageTarget.className = "text-green-700 font-bold"
        this.formTarget.reset()
        this.fileNameTarget.textContent = ""
      } else {
        this.messageTarget.innerText = data.alert || "Invalid CSV data found:"
        this.messageTarget.className = "text-red-800 font-bold"

        if (data.errors) {
          data.errors.forEach(err => {
            const li = document.createElement("li")
            li.innerText = err
            this.errorListTarget.appendChild(li)
          })
        }
      }
    } catch (error) {
      this.messageTarget.innerText = "A network error occurred."
      this.messageTarget.className = "text-red-800 font-bold"
    } finally {
      this.loadingTarget.classList.add("hidden")
      this.resultsTarget.classList.remove("hidden")
    }
  }
}