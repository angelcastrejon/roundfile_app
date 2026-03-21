require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /sign_up" do
    it "renders the sign up form" do
      get sign_up_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users" do
    it "creates a new user with valid params" do
      expect {
        post users_path, params: { user: { name: "Test", email: "test@example.com", password: "foobar", password_confirmation: "foobar" } }
      }.to change(User, :count).by(1)
      expect(response).to redirect_to(user_path(User.last))
    end

    it "does not create with invalid params" do
      expect {
        post users_path, params: { user: { name: "", email: "bad", password: "short" } }
      }.not_to change(User, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /users/:id" do
    it "shows the user profile" do
      user = create(:user)
      get user_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /users/:id/edit" do
    it "redirects when not signed in" do
      user = create(:user)
      get edit_user_path(user)
      expect(response).to redirect_to(sign_in_path)
    end

    it "renders for the correct user" do
      user = create(:user)
      sign_in_as(user)
      get edit_user_path(user)
      expect(response).to have_http_status(:ok)
    end

    it "redirects when editing another user" do
      user = create(:user)
      other = create(:user)
      sign_in_as(user)
      get edit_user_path(other)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE /users/:id" do
    it "allows admin to delete a user" do
      admin = create(:user, :admin)
      target = create(:user)
      sign_in_as(admin)
      expect { delete user_path(target) }.to change(User, :count).by(-1)
    end

    it "does not allow non-admin to delete" do
      user = create(:user)
      target = create(:user)
      sign_in_as(user)
      delete user_path(target)
      expect(response).to redirect_to(root_path)
    end
  end
end
