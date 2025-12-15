module LoginSupport
  def sign_in_as(user)
    visit stress_navi_login_path
    fill_in "session_email", with: user.email
    fill_in "session_password", with: user.password
    click_button "Sign in"
  end
end