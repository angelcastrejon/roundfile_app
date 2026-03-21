require "rails_helper"

RSpec.describe "Admin::Comments", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:resume) { create(:resume, user: user) }
  let(:comment) { create(:comment, user: user, resume: resume) }

  before { sign_in_as(admin) }

  describe "GET /admin/comments" do
    it "lists all comments" do
      comment # create the comment
      get admin_comments_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /admin/comments/:id" do
    it "deletes a comment" do
      comment # create the comment
      expect {
        delete admin_comment_path(comment)
      }.to change(Comment, :count).by(-1)
      expect(response).to redirect_to(admin_comments_path)
    end
  end
end
