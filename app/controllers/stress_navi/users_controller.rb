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

      respond_to do |format|
        format.html do
          @users = @users.page(params[:page]).per(10)
        end
        format.csv do
          USER_LOGGER.info("User CSV Download: Operator ID #{current_user.id} \n exported #{@users.count} records. \n IP: #{request.remote_ip}")
          csv_data = User.generate_csv(@users)
          send_data csv_data, filename: "users-#{Date.today}.csv"
        end
      end

    end

    def show
      @user = User.find(params[:id])

      # 直近2週間(14日間)のデータを、古い順(グラフは左から右へ流れるため)に取得
      # beginning_of_day をつけることで「2週間前の0時0分」から検索します
      range = 2.weeks.ago.beginning_of_day..Time.current
      @recent_surveys = @user.surveys.where(created_at: range).order(created_at: :asc)

      # グラフ用にデータを整形（配列にする）
      @chart_labels = @recent_surveys.map { |s| s.created_at.strftime('%m/%d') }
      
      # 縦軸: 点数
      @chart_data = @recent_surveys.map { |s| s.total_score }

      @border_line = Array.new(@chart_labels.length, 15)
    end

    def new
      @user = User.new
      @headquarters = Headquarter.all
      @departments  = Department.all
    end

    def create
      @user = User.new(user_params)
      begin
        if @user.save
          USER_LOGGER.info("Operator ID #{current_user.id} \n User Create: Target ID #{@user.id}")
          redirect_to new_stress_navi_user_path, notice: "User created successfully."
        else
          @headquarters = Headquarter.all
          @departments  = Department.all
          render :new, status: :unprocessable_entity
        end
      rescue => e
        USER_LOGGER.error("User Create Failed: Operator ID #{current_user.id} \n System Error: #{e.message}")
        render file: Rails.root.join('public/500.html'), status: :internal_server_error, layout: false
      end
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      
      begin
      if @user.update(user_params)
        USER_LOGGER.info("Operator ID #{current_user.id} \n User Update: Target ID #{@user.id}")
        redirect_to stress_navi_users_path, notice: "User updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
      rescue => e
        USER_LOGGER.error("User Update Failed: Operator ID #{current_user.id} \n System Error: #{e.message}")
        render file: Rails.root.join('public/500.html'), status: :internal_server_error, layout: false
      end
    end

    def destroy
      user = User.find(params[:id]).destroy
      
      redirect_to stress_navi_users_path, notice: "User deleted successfully."
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :department_id)
    end

  end
end
