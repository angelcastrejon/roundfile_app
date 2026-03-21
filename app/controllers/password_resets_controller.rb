class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user
      raw_token = user.generate_password_reset!
      UserMailer.password_reset(user, raw_token).deliver_later
      Rails.logger.info "[AUTH] Password reset requested: user=#{user.id} ip=#{request.remote_ip}"
    else
      Rails.logger.warn "[AUTH] Password reset for unknown email: ip=#{request.remote_ip}"
    end

    # Always show success to prevent email enumeration.
    redirect_to sign_in_path, notice: "If that email exists, we sent password reset instructions."
  end

  def edit
    @user = User.find_by_reset_token(params[:token])
    if @user.nil?
      redirect_to new_password_reset_path, alert: "Invalid or expired reset link."
    end
  end

  def update
    @user = User.find_by_reset_token(params[:token])

    if @user.nil?
      redirect_to new_password_reset_path, alert: "Invalid or expired reset link."
    elsif @user.update(password_params)
      @user.clear_password_reset!
      sign_in(@user)
      Rails.logger.info "[AUTH] Password reset completed: user=#{@user.id} ip=#{request.remote_ip}"
      redirect_to my_resumes_path, notice: "Password has been reset."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
