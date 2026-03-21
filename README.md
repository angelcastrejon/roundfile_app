# Roundfile

Resume builder and collaboration tool. Create modular resumes from reusable sections, share them with others, and get feedback through comments and star ratings.

Originally a Rails 3 class project by Angel Castrejon, Briana Fulfer, Peter Lew, Muedeh Pishavaei, and Moohanad Rasheed. Modernized to Rails 8 in 2026.

## Stack

- **Ruby** 3.3.6
- **Rails** 8.1
- **Database:** PostgreSQL
- **CSS:** Tailwind CSS v4
- **JS:** Hotwire (Turbo + Stimulus), Import Maps
- **Auth:** `has_secure_password` (bcrypt)
- **Tests:** RSpec, FactoryBot, Shoulda Matchers, Capybara

## Setup

```bash
bin/setup              # Install deps, create DB, run migrations
bin/rails db:seed      # Load sample data (11 users, resumes, comments, ratings)
bin/dev                # Start the dev server
```

Admin login: `admin@roundfile.com` / `password`

## Tests

```bash
bin/rails spec         # Run full test suite (68 examples)
```

## Features

- **Users:** Registration, authentication, profiles with Gravatar
- **Sections:** Reusable content blocks (Contact, Objective, Skills, Education, Employment History, etc.)
- **Resumes:** Compose from sections with drag-and-drop ordering
- **Comments:** Inline comments on any resume
- **Ratings:** 1-5 star ratings (one per user per resume)
- **Admin:** User management

## Project Structure

```
app/
├── controllers/
│   ├── concerns/authentication.rb   # Session-based auth
│   ├── users_controller.rb          # User CRUD
│   ├── sessions_controller.rb       # Sign in/out
│   ├── resumes_controller.rb        # Resume CRUD + browse
│   ├── sections_controller.rb       # Section CRUD
│   ├── resume_sections_controller.rb # Manage sections in resumes
│   ├── comments_controller.rb       # Nested under resumes
│   └── ratings_controller.rb        # Nested under resumes
├── models/
│   ├── user.rb            # has_secure_password, normalizes email
│   ├── resume.rb          # has_many sections through resume_sections
│   ├── section.rb         # TYPES constant, belongs_to user
│   ├── resume_section.rb  # Join model with position ordering
│   ├── comment.rb
│   ├── rating.rb          # 1-5, unique per user/resume
│   └── current.rb         # CurrentAttributes for request-scoped user
└── views/                 # Tailwind CSS, Turbo-powered forms
```

## Old App

The original Rails 3.0.12 app is preserved in the `old/` directory for reference.
