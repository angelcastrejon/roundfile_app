require "rails_helper"

RSpec.describe Rating, type: :model do
  describe "validations" do
    it { should validate_presence_of(:score) }
    it { should validate_inclusion_of(:score).in_range(1..5) }

    it "enforces one rating per user per resume" do
      rating = create(:rating)
      duplicate = build(:rating, user: rating.user, resume: rating.resume)
      expect(duplicate).not_to be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:resume) }
    it { should belong_to(:user) }
  end
end
