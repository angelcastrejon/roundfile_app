require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(50) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_length_of(:password).is_at_least(8) }

    it "rejects invalid emails" do
      %w[user@foo,com user_at_foo.org].each do |bad_email|
        subject.email = bad_email
        expect(subject).not_to be_valid
      end
    end

    it "accepts valid emails" do
      %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp].each do |good_email|
        subject.email = good_email
        expect(subject).to be_valid
      end
    end
  end

  describe "associations" do
    it { should have_many(:resumes).dependent(:destroy) }
    it { should have_many(:sections).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:ratings).dependent(:destroy) }
  end

  describe "has_secure_password" do
    it "authenticates with correct password" do
      user = create(:user, password: "foobar12", password_confirmation: "foobar12")
      expect(user.authenticate("foobar12")).to eq(user)
    end

    it "does not authenticate with wrong password" do
      user = create(:user, password: "foobar12", password_confirmation: "foobar12")
      expect(user.authenticate("wrong")).to be_falsey
    end
  end

  describe "email normalization" do
    it "downcases and strips email" do
      user = create(:user, email: "  FOO@BAR.COM  ")
      expect(user.email).to eq("foo@bar.com")
    end
  end

  describe "#gravatar_url" do
    it "returns a gravatar URL" do
      user = build(:user, email: "test@example.com")
      expect(user.gravatar_url).to include("gravatar.com/avatar/")
    end
  end
end
