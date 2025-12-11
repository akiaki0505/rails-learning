import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["list", "template", "departmentTemplate", "loading"]
    
    connect() {
        this.fetchData()
    }
    
    async fetchData() {
        const query = `
            query {
                headquarters {
                    id
                    name
                    code
                    departments {
                        id
                        name
                    }
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
            const headquarters = json.data?.headquarters || []
            this.renderData(headquarters)
        } catch (error) {
            console.error("Error fetching headquarters:", error)
            this.loadingTarget.textContent = "Error loading data."
        }
    }
    
    renderData(headquarters) {
        this.loadingTarget.classList.add("hidden")
        this.listTarget.classList.remove("hidden")
        
        const treeRoot = document.getElementById('tree-root')
        if (!treeRoot) return
        treeRoot.innerHTML = ""

        if (headquarters.length === 0) {
            treeRoot.innerHTML = '<p class="text-gray-500 italic">No headquarters found.</p>'
            return
        }
        
        headquarters.forEach(hq => {
            // 本部テンプレートを複製
            const clone = this.templateTarget.content.cloneNode(true)
            
            clone.querySelector(".js-code").textContent = hq.code || ""
            clone.querySelector(".js-name").textContent = hq.name

            const editBtn = clone.querySelector(".js-edit-btn")
            if (editBtn) {
                editBtn.href = `/stress_navi/headquarters/${hq.id}/edit`
            }
            
            // 部署リストの生成 (HTML文字列を使わずDOM操作で行う)
            const deptContainer = clone.querySelector(".js-departments")
            
            if (deptContainer) {
                if (hq.departments && hq.departments.length > 0) {
                    
                    hq.departments.forEach((dept, index) => {
                        // 部署用テンプレートを複製
                        const deptClone = this.departmentTemplateTarget.content.cloneNode(true)

                        // 部署名をセット
                        deptClone.querySelector(".js-dept-name").textContent = dept.name

                        // 線の高さを制御 (DOMのクラスリスト操作)
                        const isLast = index === hq.departments.length - 1
                        const line = deptClone.querySelector(".js-dept-line")
                        
                        if (line) {
                            if (isLast) {
                                line.classList.remove("h-full")
                                line.classList.add("h-1/2")
                            } else {
                                line.classList.add("h-full")
                                line.classList.remove("h-1/2")
                            }
                        }
                        deptContainer.appendChild(deptClone)
                    })
                } else {
                    deptContainer.innerHTML = '<p class="text-xs text-gray-400 italic pl-2">No departments.</p>'
                }
            }
            treeRoot.appendChild(clone)
        })
    }

    toggle(event) {
        const group = event.currentTarget.closest('.group')
        if (!group) return
        const deptList = group.querySelector('.js-departments')
        const chevron = group.querySelector('.js-chevron')
        deptList.classList.toggle('hidden')
        if (chevron) {
            if (deptList.classList.contains('hidden')) {
                chevron.classList.remove('rotate-180')
            } else {
                chevron.classList.add('rotate-180')
            }
        }
    }
}