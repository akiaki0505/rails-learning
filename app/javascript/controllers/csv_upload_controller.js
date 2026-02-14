import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "loading", "results", "errorList", "message", "fileName"]

  updateFileName(event) {
    const input = event.target
    if (input.files && input.files[0]) {
      this.fileNameTarget.textContent = "Selected: " + input.files[0].name
    }
  }

  // app/javascript/controllers/csv_upload_controller.js

  async submit(event) {
    event.preventDefault();
    
    this.loadingTarget.classList.remove("hidden");
    this.resultsTarget.classList.add("hidden");

    const formData = new FormData(this.formTarget);

    try {
      const response = await fetch(this.formTarget.action, {
        method: "POST",
        body: formData,
        headers: { 
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content 
        }
      });

      const data = await response.json();

      if (response.ok) {
        if (data.location) {
          // 💡 サーバーから指定されたURLへ画面を切り替える
          window.location.href = data.location;
        }
      } else {
        // エラー表示処理（既存のコード）
        this.applyStyle("error"); // 前に作ったスタイル適用メソッド
        this.messageTarget.innerText = data.alert || "Invalid CSV data found:";
        this.errorListTarget.innerHTML = "";
        if (data.errors) {
          data.errors.forEach(err => {
            const li = document.createElement("li");
            li.innerText = err;
            this.errorListTarget.appendChild(li);
          });
        }
        this.loadingTarget.classList.add("hidden");
        this.resultsTarget.classList.remove("hidden");
      }
    } catch (error) {
      console.error(error); // デバッグ用にコンソールにエラーを出す
      this.messageTarget.innerText = "A network error occurred.";
      this.loadingTarget.classList.add("hidden");
      this.resultsTarget.classList.remove("hidden");
    }
  }
}