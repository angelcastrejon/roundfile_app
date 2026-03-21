require "rails_helper"

RSpec.describe "Ratings", type: :request do
  describe "POST /resumes/:resume_id/ratings" do
    it "creates a rating when signed in" do
      user = create(:user)
      resume = create(:resume)
      sign_in_as(user)
      expect {
        post resume_ratings_path(resume), params: { rating: { score: 5 } }
      }.to change(Rating, :count).by(1)
    end

    it "does not allow duplicate ratings" do
      user = create(:user)
      resume = create(:resume)
      create(:rating, user: user, resume: resume)
      sign_in_as(user)
      expect {
        post resume_ratings_path(resume), params: { rating: { score: 3 } }
      }.not_to change(Rating, :count)
    end
  end
end
