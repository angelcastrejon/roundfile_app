FactoryBot.define do
  factory :resume_section do
    resume
    section
    sequence(:position) { |n| n }
  end
end
