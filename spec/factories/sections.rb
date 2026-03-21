FactoryBot.define do
  factory :section do
    sequence(:title) { |n| "Section #{n}" }
    section_type { "Skills" }
    content { "Some content here." }
    user

    Section::TYPES.each do |type|
      trait type.parameterize(separator: "_").to_sym do
        section_type { type }
      end
    end
  end
end
