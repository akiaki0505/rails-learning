module StressNavi
  class SessionsController < ApplicationController
    layout 'survey/application'
    skip_before_action :require_login, only: [:new, :create]
    def new
      # ログインフォーム表示
      #@BCrypt = BCrypt::Password.create("password123")
    end

    def create
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to stress_navi_dashboard_path
      else
        flash.now[:alert] = "Incorrect email or password."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:user_id)
      redirect_to stress_navi_login_path, notice: "Signed out successfully."
    end
  end
end
