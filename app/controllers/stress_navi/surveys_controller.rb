module StressNavi
  class SurveysController < ApplicationController
    layout 'survey/application'
    skip_before_action :require_login, only: [:new, :create]
    def new
      @survey = Survey.new
      if params[:user_id].present?
        @survey.user_id = params[:user_id]
      end
    end

    def create
      @survey = Survey.new(survey_params)
      user = @survey.user
      
      if user
        @survey.department = user.department
        @survey.headquarter = user.department&.headquarter
      end
      
      if @survey.save
        redirect_to complete_stress_navi_surveys_path
      else
        render :new
      end
    end

    def complete
      
    end

    private

    def survey_params
      params.require(:survey).permit(:q1, :q2, :q3, :q4, :q5, :user_id)
    end

  end
end