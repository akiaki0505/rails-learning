import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "loading"]

  async submit(event) {
    event.preventDefault()

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
        // 成功したら一覧画面へ（サーバーからリダイレクト先URLをもらう）
        window.location.href = data.location
      } else {
        alert(data.alert || "An error occurred during import.")
        this.loadingTarget.classList.add("hidden")
      }
    } catch (error) {
      console.error(error)
      alert("A network error occurred.")
      this.loadingTarget.classList.add("hidden")
    }
  }
}