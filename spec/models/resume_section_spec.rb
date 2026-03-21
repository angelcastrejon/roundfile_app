require "rails_helper"

RSpec.describe ResumeSection, type: :model do
  describe "validations" do
    it { should validate_presence_of(:position) }

    it "enforces uniqueness of section per resume" do
      rs = create(:resume_section)
      duplicate = build(:resume_section, resume: rs.resume, section: rs.section)
      expect(duplicate).not_to be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:resume) }
    it { should belong_to(:section) }
  end
end
