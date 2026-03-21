require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "GET /sign_in" do
    it "renders the sign in form" do
      get sign_in_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /session" do
    it "signs in with valid credentials" do
      user = create(:user, password: "foobar12", password_confirmation: "foobar12")
      post session_path, params: { email: user.email, password: "foobar12" }
      expect(response).to redirect_to(my_resumes_path)
    end

    it "does not sign in with bad credentials" do
      create(:user, email: "test@example.com")
      post session_path, params: { email: "test@example.com", password: "wrong" }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /sign_out" do
    it "signs out" do
      user = create(:user)
      sign_in_as(user)
      delete sign_out_path
      expect(response).to redirect_to(root_path)
    end
  end
end
