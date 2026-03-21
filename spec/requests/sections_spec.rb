require "rails_helper"

RSpec.describe "Sections", type: :request do
  describe "POST /sections" do
    it "creates a section when signed in" do
      user = create(:user)
      sign_in_as(user)
      expect {
        post sections_path, params: { section: { section_type: "Skills", title: "My Skills", content: "Ruby, Rails" } }
      }.to change(Section, :count).by(1)
    end
  end

  describe "PATCH /sections/:id" do
    it "updates own section" do
      user = create(:user)
      section = create(:section, user: user)
      sign_in_as(user)
      patch section_path(section), params: { section: { title: "Updated" } }
      expect(section.reload.title).to eq("Updated")
    end

    it "does not update another user's section" do
      user = create(:user)
      other_section = create(:section)
      sign_in_as(user)
      patch section_path(other_section), params: { section: { title: "Hacked" } }
      expect(response).to redirect_to(root_path)
    end
  end
end
