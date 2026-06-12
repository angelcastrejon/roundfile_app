class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      sign_in(user)
      Rails.logger.info "[AUTH] Login success: user=#{user.id} ip=#{request.remote_ip}"
      redirect_back_or(my_resumes_path)
    else
      Rails.logger.warn "[AUTH] Login failure: email=#{params[:email]&.to_s&.split('@')&.first&.truncate(3, omission: '***')}@*** ip=#{request.remote_ip}"
      flash.now[:alert] = "Invalid email/password combination."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    Rails.logger.info "[AUTH] Logout: user=#{current_user&.id} ip=#{request.remote_ip}"
    sign_out
    redirect_to root_path, notice: "Signed out successfully."
  end
end
