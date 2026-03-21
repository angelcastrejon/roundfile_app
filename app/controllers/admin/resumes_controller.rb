module Admin
  class ResumesController < BaseController
    before_action :set_resume, only: [:show, :destroy]

    def index
      @pagy, @resumes = pagy(
        Resume.includes(:user, :ratings, :comments).order(created_at: :desc),
        items: 20
      )
    end

    def show
      @comments = @resume.comments.includes(:user).order(created_at: :desc)
      @sections = @resume.resume_sections.includes(:section).order(:position)
    end

    def destroy
      Rails.logger.info "[ADMIN] Resume deleted: resume=#{@resume.id} owner=#{@resume.user_id} by=#{current_user.id} ip=#{request.remote_ip}"
      @resume.destroy
      redirect_to admin_resumes_path, notice: "Resume deleted."
    end

    private

    def set_resume
      @resume = Resume.find(params[:id])
    end
  end
end
