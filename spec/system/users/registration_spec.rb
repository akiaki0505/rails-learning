require 'rails_helper'

RSpec.describe "UserRegistration", type: :system do
  let!(:admin) { create(:user, email: "admin@example.com") }

  before do
    sign_in_as(admin)
  end

  describe "ユーザー新規登録" do
    context "入力内容が正しい場合" do
      it "ユーザーが新規作成され、一覧画面にリダイレクトされる" do
        visit new_stress_navi_user_path
  
        select "開発本部", from: "Headquarter"
        select "開発部", from: "Department"

        fill_in "regist_name", with: "新人 太郎"
        fill_in "regist_email", with: "new_face@example.com"

        fill_in "regist_password", with: "password123"
        fill_in "regist_password_confirmation", with: "password123"

        expect {
          find("button", text: "Register", visible: false).click
        }.to change(User, :count).by(1)
         
        expect(current_path).to eq stress_navi_users_path
        expect(page).to have_content "User created successfully."
        expect(page).to have_content "新人 太郎"
      end
    end
  end
end