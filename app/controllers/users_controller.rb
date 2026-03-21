class UsersController < ApplicationController
  before_action :authenticate!, only: [:index, :edit, :update, :destroy]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update]
  before_action :authorize_admin!, only: [:destroy]

  def index
    @pagy, @users = pagy(User.order(:name))
  end

  def show
    @resumes = @user.resumes.order(updated_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in(@user)
      redirect_to @user, notice: "Welcome to Roundfile!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: "User deleted."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_owner!
    redirect_to root_path, alert: "Not authorized." unless current_user == @user
  end

  def user_params
    params.expect(user: [:name, :email, :password, :password_confirmation])
  end
end
