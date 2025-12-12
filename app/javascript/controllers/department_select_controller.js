import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["headquarter", "department"]
    
    connect() {
        this.allOptions = Array.from(this.departmentTarget.querySelectorAll("option")).slice(1);
        
        this.filter();
    }
    
    filter() {
        const selectedHeadquarterId = this.headquarterTarget.value;
        const departmentSelect = this.departmentTarget;
        
        departmentSelect.length = 1;
        
        if (!selectedHeadquarterId) return
        
        this.allOptions.forEach(option => {
            if (option.dataset.headquarterId == selectedHeadquarterId) {
                departmentSelect.appendChild(option);
            }
        })
        
        departmentSelect.value = "";
    }
}