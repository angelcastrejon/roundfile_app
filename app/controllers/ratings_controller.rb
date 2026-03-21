class RatingsController < ApplicationController
  before_action :authenticate!
  before_action :set_resume

  def create
    @rating = @resume.ratings.build(rating_params.merge(user: current_user))
    if @rating.save
      redirect_to @resume, notice: "Rating submitted."
    else
      redirect_to @resume, alert: "Could not submit rating."
    end
  end

  def update
    @rating = current_user.ratings.find_by!(resume: @resume)
    if @rating.update(rating_params)
      redirect_to @resume, notice: "Rating updated."
    else
      redirect_to @resume, alert: "Could not update rating."
    end
  end

  def destroy
    @rating = current_user.ratings.find_by!(resume: @resume)
    @rating.destroy
    redirect_to @resume, notice: "Rating removed."
  end

  private

  def set_resume
    @resume = Resume.find(params[:resume_id])
  end

  def rating_params
    params.expect(rating: [:score])
  end
end
