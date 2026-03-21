require "rails_helper"

RSpec.describe Section, type: :model do
  describe "validations" do
    it { should validate_presence_of(:section_type) }
    it { should validate_inclusion_of(:section_type).in_array(Section::TYPES) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:resume_sections).dependent(:destroy) }
    it { should have_many(:resumes).through(:resume_sections) }
  end
end
