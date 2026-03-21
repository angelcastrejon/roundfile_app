require "rails_helper"

RSpec.describe "Comments", type: :request do
  describe "POST /resumes/:resume_id/comments" do
    it "creates a comment when signed in" do
      user = create(:user)
      resume = create(:resume)
      sign_in_as(user)
      expect {
        post resume_comments_path(resume), params: { comment: { body: "Nice resume!" } }
      }.to change(Comment, :count).by(1)
    end
  end

  describe "DELETE /resumes/:resume_id/comments/:id" do
    it "deletes own comment" do
      user = create(:user)
      resume = create(:resume)
      comment = create(:comment, user: user, resume: resume)
      sign_in_as(user)
      expect { delete resume_comment_path(resume, comment) }.to change(Comment, :count).by(-1)
    end
  end
end
