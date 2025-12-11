module StressNavi
  class HeadquartersController < ApplicationController
    layout 'stressNavi/admin/application'
    def index
      
    end

    def new
      @headquarter = Headquarter.new
    end

    def edit
      @headquarter_id = params[:id]
    end
  end
end
