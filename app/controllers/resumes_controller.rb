class ResumesController < ApplicationController
  before_action :authenticate!, except: [:index, :show, :user_resumes]
  before_action :set_resume, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  def index
    @pagy, @resumes = pagy(Resume.includes(:user, :ratings).order(updated_at: :desc))
  end

  def show
    @resume_sections = @resume.resume_sections.includes(:section)
    @comments = @resume.comments.includes(:user).order(created_at: :desc)
    @user_rating = current_user&.ratings&.find_by(resume: @resume)
    @comment = Comment.new
    @rating = Rating.new
  end

  def new
    @resume = current_user.resumes.build
  end

  def create
    @resume = current_user.resumes.build(resume_params)
    if @resume.save
      redirect_to edit_resume_path(@resume), notice: "Resume created! Now add sections."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @available_sections = current_user.sections.order(:section_type)
    @resume_sections = @resume.resume_sections.includes(:section)
  end

  def update
    if @resume.update(resume_params)
      redirect_to @resume, notice: "Resume updated."
    else
      @available_sections = current_user.sections.order(:section_type)
      @resume_sections = @resume.resume_sections.includes(:section)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @resume.destroy
    redirect_to my_resumes_path, notice: "Resume deleted."
  end

  def my_resumes
    @resumes = current_user.resumes.order(updated_at: :desc)
  end

  def user_resumes
    @users = User.order(:name)
    if params[:user_id].present?
      @selected_user = User.find(params[:user_id])
      @resumes = @selected_user.resumes.order(updated_at: :desc)
    end
  end

  private

  def set_resume
    @resume = Resume.find(params[:id])
  end

  def authorize_owner!
    redirect_to root_path, alert: "Not authorized." unless @resume.user == current_user
  end

  def resume_params
    params.expect(resume: [:name])
  end
end
