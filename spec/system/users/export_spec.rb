require 'rails_helper'

RSpec.describe "UserExport", type: :system do
  let!(:admin) { create(:user, email: "admin@example.com") }
  let!(:target_user) { create(:user, name: "CSV確認太郎", email: "export_check@example.com") }

  before do
    sign_in_as(admin)
  end

  describe "CSV出力機能" do
    it "CSVファイルが正しくダウンロードでき、中身のデータが正しい" do
      visit stress_navi_users_path

      click_link "Export CSV"

      expect(page.response_headers['Content-Type']).to include 'text/csv'
      expect(page.response_headers['Content-Disposition']).to include 'users'

      csv_content = page.body

      expect(csv_content).to include "ID"
      expect(csv_content).to include "名前"
      expect(csv_content).to include "メールアドレス"
      expect(csv_content).to include "登録日時"

      expect(csv_content).to include "CSV確認太郎"
      expect(csv_content).to include "export_check@example.com"
    end
  end
end