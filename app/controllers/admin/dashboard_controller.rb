module Admin
  class DashboardController < BaseController
    def show
      @total_users = User.count
      @total_resumes = Resume.count
      @total_comments = Comment.count
      @total_ratings = Rating.count
      @total_sections = Section.count

      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_resumes = Resume.includes(:user).order(created_at: :desc).limit(5)
      @recent_comments = Comment.includes(:user, :resume).order(created_at: :desc).limit(5)
    end
  end
end
