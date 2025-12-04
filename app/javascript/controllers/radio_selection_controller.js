import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    update(event) {
        const clickedRadio = event.target
        const groupName = clickedRadio.name
        const radiosInGroup = document.querySelectorAll(`input[name="${groupName}"]`)
        
        radiosInGroup.forEach(radio => {
            const label = radio.closest('label')
            if (!label) return
            
            if (radio.checked) {
                label.classList.add('bg-indigo-100', 'border-indigo-500')
            } else {
                label.classList.remove('bg-indigo-100', 'border-indigo-500')
            }
        })
    }
}