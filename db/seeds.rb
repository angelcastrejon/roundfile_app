require "faker"

puts "Seeding database..."

# Admin user
admin = User.find_or_create_by!(email: "admin@roundfile.com") do |u|
  u.name = "Admin User"
  u.password = "password"
  u.password_confirmation = "password"
  u.admin = true
end
puts "  Created admin: #{admin.email}"

# Sample users
users = 10.times.map do |i|
  User.find_or_create_by!(email: Faker::Internet.unique.email) do |u|
    u.name = Faker::Name.name
    u.password = "password"
    u.password_confirmation = "password"
  end
end
puts "  Created #{users.count} sample users"

# Create sections for each user
all_users = [admin] + users
all_users.each do |user|
  section_data = [
    { section_type: "Contact", title: "Contact Information",
      content: "#{user.name}\n#{Faker::Address.full_address}\n#{Faker::PhoneNumber.phone_number}\n#{user.email}" },
    { section_type: "Objective", title: "Career Objective",
      content: Faker::Lorem.paragraph(sentence_count: 3) },
    { section_type: "Education", title: "University Education",
      content: "#{Faker::University.name}\nB.S. in #{Faker::Educator.subject}, #{rand(2015..2024)}\nGPA: #{(rand(30..40) / 10.0).round(1)}" },
    { section_type: "Skills", title: "Technical Skills",
      content: Faker::Lorem.words(number: 8).map(&:capitalize).join(", ") },
    { section_type: "Employment History", title: "#{Faker::Company.name} - #{Faker::Job.title}",
      content: "#{Faker::Date.between(from: 3.years.ago, to: 1.year.ago).strftime('%B %Y')} - Present\n#{Faker::Lorem.paragraph(sentence_count: 4)}" },
    { section_type: "References", title: "Professional References",
      content: "Available upon request." }
  ]

  section_data.each do |data|
    user.sections.find_or_create_by!(title: data[:title]) do |s|
      s.section_type = data[:section_type]
      s.content = data[:content]
    end
  end
end
puts "  Created sections for all users"

# Create resumes and add sections
all_users.each do |user|
  resume = user.resumes.find_or_create_by!(name: "#{user.name.split.first}'s Resume")
  user.sections.each_with_index do |section, i|
    ResumeSection.find_or_create_by!(resume: resume, section: section) do |rs|
      rs.position = i + 1
    end
  end
end
puts "  Created resumes with sections"

# Add comments and ratings
resumes = Resume.all
all_users.each do |user|
  # Comment on 3 random resumes (not own)
  resumes.where.not(user: user).sample(3).each do |resume|
    Comment.find_or_create_by!(user: user, resume: resume) do |c|
      c.body = Faker::Lorem.sentence(word_count: rand(5..15))
    end
  end

  # Rate 5 random resumes (not own)
  resumes.where.not(user: user).sample(5).each do |resume|
    Rating.find_or_create_by!(user: user, resume: resume) do |r|
      r.score = rand(3..5)
    end
  end
end
puts "  Created comments and ratings"

puts "Done! #{User.count} users, #{Resume.count} resumes, #{Section.count} sections, #{Comment.count} comments, #{Rating.count} ratings"
