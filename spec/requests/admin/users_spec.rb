require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }

  before { sign_in_as(admin) }

  describe "GET /admin/users" do
    it "lists all users" do
      user # create the user
      get admin_users_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects non-admin" do
      sign_in_as(user)
      get admin_users_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /admin/users/:id" do
    it "shows user details" do
      get admin_user_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/users/:id/toggle_admin" do
    it "grants admin to a regular user" do
      patch toggle_admin_admin_user_path(user)
      expect(user.reload.admin?).to be true
      expect(response).to redirect_to(admin_users_path)
    end

    it "revokes admin from an admin user" do
      other_admin = create(:user, :admin)
      patch toggle_admin_admin_user_path(other_admin)
      expect(other_admin.reload.admin?).to be false
    end

    it "prevents admin from toggling their own status" do
      patch toggle_admin_admin_user_path(admin)
      expect(admin.reload.admin?).to be true
      expect(response).to redirect_to(admin_users_path)
    end
  end

  describe "DELETE /admin/users/:id" do
    it "deletes a user" do
      user # create the user
      expect {
        delete admin_user_path(user)
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(admin_users_path)
    end

    it "prevents admin from deleting themselves" do
      expect {
        delete admin_user_path(admin)
      }.not_to change(User, :count)
    end
  end
end
