module StressNavi
  class SessionsController < ApplicationController
    def new
      # ログインフォーム表示
    end

    def create
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to stress_navi_surveys_new_path, notice: "ログインしました。"
      else
        flash.now[:alert] = "メールアドレスまたはパスワードが正しくありません。"
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:user_id)
      redirect_to stress_navi_login_path, notice: "ログアウトしました。"
    end
  end
end
