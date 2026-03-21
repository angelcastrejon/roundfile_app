class CommentsController < ApplicationController
  before_action :authenticate!
  before_action :set_resume
  before_action :set_comment, only: [:edit, :update, :destroy]
  before_action :authorize_comment_owner!, only: [:edit, :update, :destroy]

  def create
    @comment = @resume.comments.build(comment_params.merge(user: current_user))
    if @comment.save
      redirect_to @resume, notice: "Comment added."
    else
      redirect_to @resume, alert: "Could not add comment."
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to @resume, notice: "Comment updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    redirect_to @resume, notice: "Comment deleted."
  end

  private

  def set_resume
    @resume = Resume.find(params[:resume_id])
  end

  def set_comment
    @comment = @resume.comments.find(params[:id])
  end

  def authorize_comment_owner!
    redirect_to @resume, alert: "Not authorized." unless @comment.user == current_user
  end

  def comment_params
    params.expect(comment: [:body])
  end
end
