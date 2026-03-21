require "rails_helper"

RSpec.describe "Admin::Resumes", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:resume) { create(:resume, user: user) }

  before { sign_in_as(admin) }

  describe "GET /admin/resumes" do
    it "lists all resumes" do
      resume # create the resume
      get admin_resumes_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /admin/resumes/:id" do
    it "shows resume details" do
      get admin_resume_path(resume)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /admin/resumes/:id" do
    it "deletes a resume" do
      resume # create the resume
      expect {
        delete admin_resume_path(resume)
      }.to change(Resume, :count).by(-1)
      expect(response).to redirect_to(admin_resumes_path)
    end

    it "redirects non-admin" do
      sign_in_as(user)
      delete admin_resume_path(resume)
      expect(response).to redirect_to(root_path)
    end
  end
end
