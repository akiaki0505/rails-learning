module StressNavi
  class UsersController < ApplicationController
    layout 'stressNavi/admin/application'
    def index
      @users = User.order(id: :desc)

      if params[:name].present?
        @users = @users.where("name LIKE ?", "%#{params[:name]}%")
      end

      if params[:email].present?
        @users = @users.where("email LIKE ?", "%#{params[:email]}%")
      end

    end

    def show
      @user = User.find(params[:id])

      # 1. 直近2週間(14日間)のデータを、古い順(グラフは左から右へ流れるため)に取得
      # beginning_of_day をつけることで「2週間前の0時0分」から検索します
      range = 2.weeks.ago.beginning_of_day..Time.current
      @recent_surveys = @user.surveys.where(created_at: range).order(created_at: :asc)

      # 2. グラフ用にデータを整形（配列にする）
      # 横軸: 日付 (例: "12/01")
      @chart_labels = @recent_surveys.map { |s| s.created_at.strftime('%m/%d') }
      
      # 縦軸: 点数
      @chart_data = @recent_surveys.map { |s| s.total_score }

      @border_line = Array.new(@chart_labels.length, 15)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to new_stress_navi_user_path, notice: "User created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      
      if @user.update(user_params)
        redirect_to stress_navi_user_list_path, notice: "User updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      user = User.find(params[:id]).destroy
      
      redirect_to stress_navi_user_list_path, notice: "User deleted successfully."
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

  end
end
