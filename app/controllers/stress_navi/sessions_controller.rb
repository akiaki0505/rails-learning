module StressNavi
  class SessionsController < ApplicationController
    layout 'survey/application'
    skip_before_action :require_login, only: [:new, :create]
    def new

    end

    def create
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        LOGIN_LOGGER.info("Login Successful: User ID #{user.id} from IP #{request.remote_ip}")

        session[:user_id] = user.id
        session[:last_active_at] = Time.current
        redirect_to stress_navi_dashboard_path
      else
        LOGIN_LOGGER.warn("Login Failed: Attempt for email '#{params[:email]}' from IP #{request.remote_ip}")
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
