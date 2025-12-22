import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["resultArea", "loading", "content", "title", "score"]
    
    async analyze(event) {
        event.preventDefault()
        const name = event.currentTarget.dataset.name
        
        this.showLoading()
        
        try {
            const response = await fetch('/stress_navi/reports/analyze', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify({ name: name })
            })
            
            const data = await response.json()
            
            this.showResult(data)
        
        } catch (error) {
            console.error(error)
            this.contentTarget.textContent = "An error occurred. Please try again."
            this.loadingTarget.classList.add("hidden")
            this.resultAreaTarget.classList.remove("hidden")
        }
    }
    
    showLoading() {
        this.resultAreaTarget.classList.add("hidden")
        this.loadingTarget.classList.remove("hidden")
    }
    
    showResult(data) {
        this.loadingTarget.classList.add("hidden")
        this.resultAreaTarget.classList.remove("hidden")

        this.titleTarget.textContent = `Analysis Report: ${data.name}`
        
        this.scoreTarget.textContent = `Avg Stress Score: ${data.score} / 25`
        
        if (data.score >= 20) {
            this.scoreTarget.className = "text-xl font-bold text-red-600"
        } else if (data.score >= 15) {
            this.scoreTarget.className = "text-xl font-bold text-yellow-600"
        } else {
            this.scoreTarget.className = "text-xl font-bold text-green-600"
        }
        
        this.contentTarget.innerHTML = data.analysis
    }
}