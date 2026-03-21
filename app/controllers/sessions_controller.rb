class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      sign_in(user)
      redirect_back_or(my_resumes_path)
    else
      flash.now[:alert] = "Invalid email/password combination."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out
    redirect_to root_path, notice: "Signed out successfully."
  end
end
