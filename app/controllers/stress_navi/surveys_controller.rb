module StressNavi
  class SurveysController < ApplicationController
    layout 'survey/application'
    def new
      @survey = Survey.new
    end

    def create
      @survey = Survey.new(survey_params)
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
      params.require(:survey).permit(:q1, :q2, :q3, :q4, :q5)
    end

  end
end