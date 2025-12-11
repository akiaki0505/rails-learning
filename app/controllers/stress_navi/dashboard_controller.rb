module StressNavi
  class DashboardController < ApplicationController
    layout 'stressNavi/admin/application'
    def dashboard
      @user_count = User.count

      range = 1.week.ago.beginning_of_day..Time.current
      @weekly_survey_count = Survey.where(created_at: range).count
      @alert_count = Survey.where(created_at: range).where("total_score > ?", 15).count

      @headquarters = Headquarter.includes(departments: { users: :surveys }).order(:id) 
    end
  end
end
