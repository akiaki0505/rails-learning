require 'rails_helper'

RSpec.describe "Sessions", type: :system do
  let!(:user) { create(:user) }

  before do
    driven_by(:rack_test)
    # ブロックされる "www.example.com" の代わりに "127.0.0.1" を使う設定
    Capybara.app_host = 'http://127.0.0.1'
  end

  describe "ログイン機能" do
    context "入力内容が正しい場合" do
      it "ログインに成功し、ダッシュボードに遷移する" do
        visit stress_navi_login_path
        
        fill_in "session_email", with: user.email
        fill_in "session_password", with: user.password
        
        click_button "Sign in"
        
        expect(current_path).to eq stress_navi_dashboard_path
      end
    end

    context "入力内容が誤っている場合" do
      it "ログインに失敗する" do
        visit stress_navi_login_path
        
        fill_in "session_email", with: user.email
        fill_in "session_password", with: "wrong_password"
        
        click_button "Sign in"
        
        expect(page).to have_content "Incorrect email or password."
      end
    end
  end

  describe "ログアウト機能" do
    before do
      visit stress_navi_login_path
      fill_in "session_email", with: user.email
      fill_in "session_password", with: user.password
      click_button "Sign in"
    end

    it "ログアウトに成功し、ログイン画面に戻る" do
      click_button "Sign out"
      expect(current_path).to eq stress_navi_login_path
      expect(page).to have_content "Signed out successfully."
    end
  end
end