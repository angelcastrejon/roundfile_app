module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :signed_in?
  end

  private

  def current_user
    Current.user ||= if session[:user_id]
      User.find_by(id: session[:user_id])
    end
  end

  def signed_in?
    current_user.present?
  end

  def authenticate!
    unless signed_in?
      store_location
      redirect_to sign_in_path, alert: "Please sign in to access this page."
    end
  end

  def authorize_admin!
    redirect_to root_path, alert: "Not authorized." unless current_user&.admin?
  end

  def store_location
    session[:return_to] = request.fullpath if request.get?
  end

  def redirect_back_or(default)
    redirect_to(session.delete(:return_to) || default)
  end

  def sign_in(user)
    session[:user_id] = user.id
    Current.user = user
  end

  def sign_out
    session.delete(:user_id)
    Current.user = nil
  end
end
