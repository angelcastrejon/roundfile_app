FactoryBot.define do
  factory :resume do
    sequence(:name) { |n| "Resume #{n}" }
    user
  end
end
