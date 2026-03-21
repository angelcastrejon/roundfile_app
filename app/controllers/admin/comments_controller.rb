module Admin
  class CommentsController < BaseController
    before_action :set_comment, only: [:destroy]

    def index
      @pagy, @comments = pagy(
        Comment.includes(:user, :resume).order(created_at: :desc),
        items: 20
      )
    end

    def destroy
      Rails.logger.info "[ADMIN] Comment deleted: comment=#{@comment.id} author=#{@comment.user_id} by=#{current_user.id} ip=#{request.remote_ip}"
      resume = @comment.resume
      @comment.destroy
      redirect_to admin_comments_path, notice: "Comment deleted."
    end

    private

    def set_comment
      @comment = Comment.find(params[:id])
    end
  end
end
