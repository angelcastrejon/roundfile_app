module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :toggle_admin, :destroy]

    def index
      @pagy, @users = pagy(User.order(created_at: :desc), items: 20)
    end

    def show
      @resumes = @user.resumes.includes(:ratings, :comments)
    end

    def toggle_admin
      if @user == current_user
        redirect_to admin_users_path, alert: "You cannot change your own admin status."
      else
        @user.update!(admin: !@user.admin?)
        status = @user.admin? ? "granted" : "revoked"
        Rails.logger.info "[ADMIN] Admin #{status}: user=#{@user.id} by=#{current_user.id} ip=#{request.remote_ip}"
        redirect_to admin_users_path, notice: "Admin #{status} for #{@user.name}."
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: "You cannot delete yourself."
      else
        Rails.logger.info "[ADMIN] User deleted: user=#{@user.id} email=#{@user.email} by=#{current_user.id} ip=#{request.remote_ip}"
        @user.destroy
        redirect_to admin_users_path, notice: "User #{@user.name} deleted."
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
