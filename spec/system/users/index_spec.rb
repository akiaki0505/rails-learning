require 'rails_helper'

RSpec.describe "UserIndex", type: :system do
  let!(:admin) { create(:user, email: "admin@example.com") }
  let!(:other_users) { create_list(:user, 3) }
  let!(:target_user) { create(:user, name: "鈴木 検索用") }

  before do
    sign_in_as(admin)
  end

  describe "ユーザー一覧表示" do
    it "自分(admin)を含めて合計5人のユーザーが表示される" do
      visit stress_navi_users_path
      
      expect(page).to have_content "鈴木 検索用"
      expect(page).to have_content other_users.first.name
      expect(page).to have_content admin.name
    end
  end

  describe "検索機能" do
    it "名前で検索" do
      visit stress_navi_users_path

      fill_in "search_name", with: "鈴木"
      click_button "Search"

      expect(page).to have_content "鈴木 検索用"
      expect(page).not_to have_content other_users.first.name
    end
  end

end