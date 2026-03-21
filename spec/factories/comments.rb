FactoryBot.define do
  factory :comment do
    body { "This is a great resume!" }
    resume
    user
  end
end
