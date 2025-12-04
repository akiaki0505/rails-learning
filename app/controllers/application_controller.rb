class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  before_action :check_session_timeout
  before_action :require_login

  private

  def check_session_timeout
    if session[:user_id]
      last_active = session[:last_active_at]
      if last_active && last_active.to_time < 60.minutes.ago
        reset_session 
        flash[:alert] = "Your session has expired. Please sign in again."
        redirect_to stress_navi_login_path
      else
        session[:last_active_at] = Time.current
      end
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_login
    unless logged_in?
      flash[:alert] = "Please sign in to continue."
      redirect_to stress_navi_login_path
    end
  end
end