import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["name", "code", "error"]

    async submit(event) {
        event.preventDefault()
        this.errorTarget.textContent = ""

        const name = this.nameTarget.value
        const code = this.codeTarget.value

        const query = `
            mutation CreateHeadquarter($input: CreateHeadquarterInput!) {
                createHeadquarter(input: $input) {
                    headquarter {
                        id
                        name
                    }
                    errors
                }
            }
        `
        const variables = {
            input: {
                name: name,
                code: code
            }
        }

        try {
            const response = await fetch('/graphql', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify({ query, variables })
            })

            if (!response.ok) {
                throw new Error(`Server error: ${response.status}`);
            }

            const json = await response.json()
            const result = json.data?.createHeadquarter

            // GraphQLエラーチェック
            if (result?.errors && result.errors.length > 0) {
                this.errorTarget.textContent = result.errors.join(", ")
                document.getElementById('confirmation-modal').classList.add('hidden')
                return
            }
            
            window.location.href = "/stress_navi/headquarters"

        } catch (error) {
            console.error("Error:", error)
            this.errorTarget.textContent = "System Error: Failed to create."
        }
    }
}