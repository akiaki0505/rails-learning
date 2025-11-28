module StressNavi
  class DashboardController < ApplicationController
    layout 'stressNavi/admin/application'
    def dashboard
      @user_count = User.count
    end
  end
end
