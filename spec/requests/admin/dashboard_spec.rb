require "rails_helper"

RSpec.describe "Admin::Dashboard", type: :request do
  describe "GET /admin" do
    it "redirects non-admin users" do
      user = create(:user)
      sign_in_as(user)
      get admin_dashboard_path
      expect(response).to redirect_to(root_path)
    end

    it "redirects unauthenticated users" do
      get admin_dashboard_path
      expect(response).to redirect_to(sign_in_path)
    end

    it "renders for admin users" do
      admin = create(:user, :admin)
      sign_in_as(admin)
      get admin_dashboard_path
      expect(response).to have_http_status(:ok)
    end
  end
end
