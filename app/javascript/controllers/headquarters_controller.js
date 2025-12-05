import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // 3つのターゲットを定義
  // list: カードを追加していく親要素
  // template: コピー元のHTML
  // loading: ローディング表示
  static targets = ["list", "template", "loading"]

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
    // ローディングを消す
    this.loadingTarget.classList.add("hidden")

    if (headquarters.length === 0) {
      this.listTarget.innerHTML = '<p class="text-gray-500 col-span-full text-center">No headquarters found.</p>'
      return
    }

    // データ件数分ループ
    headquarters.forEach(hq => {
      // 1. テンプレートの中身を複製(クローン)する
      const clone = this.templateTarget.content.cloneNode(true)

      // 2. 複製した中身の要素を探して、データをセットする
      // (querySelectorでクラス名を指定して探します)
      clone.querySelector(".js-code").textContent = hq.code || "NO CODE"
      clone.querySelector(".js-name").textContent = hq.name
      
      // 編集ボタンなどにIDを埋め込みたい場合
      // clone.querySelector("button").dataset.id = hq.id

      // 3. リストに追加
      this.listTarget.appendChild(clone)
    })
  }
}