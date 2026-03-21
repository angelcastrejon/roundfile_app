require "rails_helper"

RSpec.describe "Resumes", type: :request do
  describe "GET /resumes" do
    it "lists all resumes" do
      create(:resume)
      get resumes_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /resumes/:id" do
    it "shows a resume" do
      resume = create(:resume)
      get resume_path(resume)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /resumes" do
    it "creates a resume when signed in" do
      user = create(:user)
      sign_in_as(user)
      expect {
        post resumes_path, params: { resume: { name: "My Resume" } }
      }.to change(Resume, :count).by(1)
    end

    it "redirects when not signed in" do
      post resumes_path, params: { resume: { name: "My Resume" } }
      expect(response).to redirect_to(sign_in_path)
    end
  end

  describe "DELETE /resumes/:id" do
    it "deletes own resume" do
      user = create(:user)
      resume = create(:resume, user: user)
      sign_in_as(user)
      expect { delete resume_path(resume) }.to change(Resume, :count).by(-1)
    end

    it "does not delete another user's resume" do
      user = create(:user)
      other_resume = create(:resume)
      sign_in_as(user)
      delete resume_path(other_resume)
      expect(response).to redirect_to(root_path)
    end
  end
end
