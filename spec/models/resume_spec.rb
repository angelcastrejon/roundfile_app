require "rails_helper"

RSpec.describe Resume, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:resume_sections).dependent(:destroy) }
    it { should have_many(:sections).through(:resume_sections) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:ratings).dependent(:destroy) }
  end

  describe "#average_rating" do
    it "returns 0 with no ratings" do
      resume = create(:resume)
      expect(resume.average_rating).to eq(0)
    end

    it "returns the average score" do
      resume = create(:resume)
      create(:rating, resume: resume, score: 4)
      create(:rating, resume: resume, score: 2)
      expect(resume.average_rating).to eq(3.0)
    end
  end
end
