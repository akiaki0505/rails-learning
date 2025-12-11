import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { id: String }
    static targets = ["name", "code", "error", "form"]
    
    connect() {
        this.fetchHeadquarter()
    }

    async fetchHeadquarter() {
        const query = `
            query {
                headquarter(id: "${this.idValue}") {
                id
                name
                code
                }
            }
        `

        try {
            const response = await fetch('/graphql', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify({ query })
            })

            const json = await response.json()
            const headquarter = json.data?.headquarter
            
            if (headquarter) {
                this.nameTarget.value = headquarter.name
                this.codeTarget.value = headquarter.code || ""
            } else {
                this.errorTarget.textContent = "Data not found."
            }
        } catch (error) {
            console.error("Error loading data:", error)
            this.errorTarget.textContent = "Failed to load data."
        }
    }
    
    async submit(event) {
        event.preventDefault()
        this.errorTarget.textContent = ""

        const name = this.nameTarget.value
        const code = this.codeTarget.value

    
    const query = `
        mutation {
            updateHeadquarter(input: {
                id: "${this.idValue}", 
                name: "${name}", 
                code: "${code}"
            }) {
                headquarter {
                    id
                    name
                }
                errors
                }
            }
        `

        try {
        const response = await fetch('/graphql', {
            method: 'POST',
            headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify({ query })
        })

        const json = await response.json()
        const result = json.data?.updateHeadquarter

        if (result?.errors && result.errors.length > 0) {
            this.errorTarget.textContent = result.errors.join(", ")
            
            if(document.getElementById('confirmation-modal')) {
                document.getElementById('confirmation-modal').classList.add('hidden')
            }
            return
        }

        window.location.href = "/stress_navi/headquarters"

        } catch (error) {
            console.error("Error updating:", error)
            this.errorTarget.textContent = "System Error: Failed to update."
            if(document.getElementById('confirmation-modal')) {
                document.getElementById('confirmation-modal').classList.add('hidden')
            }
        }
    }
}