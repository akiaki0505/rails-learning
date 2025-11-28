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
