# Roundfile Modernization Plan: Rails 3 → Rails 8 (2026)

## Strategy: Fresh Rails 8 App + Port Logic

Generate a new Rails 8 app alongside the existing code, then port models, controllers, views, and data. The old app stays as reference in the current directory.

---

## Phase 1: Scaffold the New Rails 8 App

### 1.1 Generate the app
- `rails new roundfile --database=postgresql --css=tailwind --skip-jbuilder`
- This gives us: Rails 8, Hotwire/Turbo, Importmaps, Propshaft, Tailwind CSS, PostgreSQL
- Rails 8 defaults include Solid Cache, Solid Queue, Solid Cable — keep them

### 1.2 Set up PostgreSQL
- Configure `config/database.yml` for local dev (roundfile_development, roundfile_test)
- `rails db:create`

### 1.3 Add essential gems to Gemfile
- `bcrypt` (for `has_secure_password`)
- `pagy` (replaces `will_paginate`)
- `faker` (seed data)
- Testing: `rspec-rails`, `factory_bot_rails`, `capybara`, `shoulda-matchers`

### 1.4 Set up RSpec
- `rails generate rspec:install`
- Configure `spec/rails_helper.rb` with FactoryBot, Shoulda, Capybara

---

## Phase 2: Database Schema with Rails Conventions

Create migrations using **proper Rails naming conventions** (fixing the old `userid`/`resumeid`/`orderNum` anti-patterns).

### 2.1 Users migration
```ruby
create_table :users do |t|
  t.string :name, null: false
  t.string :email, null: false
  t.string :password_digest, null: false  # bcrypt (replaces encrypted_password + salt)
  t.boolean :admin, default: false
  t.timestamps
end
add_index :users, :email, unique: true
```

### 2.2 Resumes migration
```ruby
create_table :resumes do |t|
  t.string :name, null: false
  t.references :user, null: false, foreign_key: true  # replaces 'userid'
  t.timestamps
end
```

### 2.3 Sections migration
```ruby
create_table :sections do |t|
  t.string :section_type, null: false     # replaces 'typesection'
  t.string :title, null: false
  t.text :content, null: false
  t.references :user, null: false, foreign_key: true  # replaces 'userid'
  t.timestamps
end
```

### 2.4 Resume Sections (join table) migration
```ruby
create_table :resume_sections do |t|      # replaces 'resumesections'
  t.references :resume, null: false, foreign_key: true  # replaces 'resumeid'
  t.references :section, null: false, foreign_key: true  # replaces 'sectionid'
  t.integer :position, null: false, default: 0            # replaces 'orderNum'
  t.timestamps
end
add_index :resume_sections, [:resume_id, :section_id], unique: true
```

### 2.5 Comments migration
```ruby
create_table :comments do |t|
  t.references :resume, null: false, foreign_key: true
  t.references :user, null: false, foreign_key: true
  t.text :body, null: false               # replaces 'comment'
  t.timestamps                            # replaces 'comment_time'
end
```

### 2.6 Ratings migration
```ruby
create_table :ratings do |t|
  t.references :resume, null: false, foreign_key: true
  t.references :user, null: false, foreign_key: true
  t.integer :score, null: false            # replaces 'rating_score'
  t.timestamps                             # replaces 'rate_time'
end
add_index :ratings, [:resume_id, :user_id], unique: true  # one rating per user per resume
```

---

## Phase 3: Models

### 3.1 User model
- Use `has_secure_password` (replaces entire custom SHA2 system)
- Associations: `has_many :resumes`, `has_many :sections`, `has_many :comments`, `has_many :ratings` (all `dependent: :destroy`)
- Validations: name (presence, max 50), email (presence, uniqueness, format), password (length 6..72)
- Add `normalizes :email, with: -> { _1.strip.downcase }` (Rails 7.1+)

### 3.2 Resume model
- `belongs_to :user`
- `has_many :resume_sections, -> { order(:position) }, dependent: :destroy`
- `has_many :sections, through: :resume_sections`
- `has_many :comments, dependent: :destroy`
- `has_many :ratings, dependent: :destroy`
- Method: `average_rating` (computed from ratings)
- Validates: name presence

### 3.3 Section model
- `belongs_to :user`
- `has_many :resume_sections, dependent: :destroy`
- `has_many :resumes, through: :resume_sections`
- Validates: section_type (inclusion in predefined list), title, content presence
- Constant: `TYPES = ["Contact", "Objective", "Qualifications", "Education", "Skills", "Employment History", "References", "Other"]`

### 3.4 ResumeSection model (join)
- `belongs_to :resume`
- `belongs_to :section`
- Validates: position presence, uniqueness of section scoped to resume
- Use `acts_as_list` gem or manual position management

### 3.5 Comment model
- `belongs_to :resume`
- `belongs_to :user`
- Validates: body presence

### 3.6 Rating model
- `belongs_to :resume`
- `belongs_to :user`
- Validates: score (inclusion 1..5), uniqueness of user scoped to resume

---

## Phase 4: Authentication

### 4.1 Replace hand-rolled auth with Rails 8 authentication generator
- `rails generate authentication` (Rails 8 built-in, generates User model with `has_secure_password`, sessions controller, and session model)
- Alternatively, since we have a custom User model with `name` and `admin`, we'll use `has_secure_password` directly and build a simple sessions controller
- Approach: manual `has_secure_password` + SessionsController (closest to original app's approach, educational)

### 4.2 Sessions controller
- `new` (sign in form), `create` (authenticate), `destroy` (sign out)
- Use `session[:user_id]` or Rails 8 session model
- Remember me: use signed cookies with user ID + generated token (not salt)

### 4.3 Authentication concern
- `Current.user` pattern (Rails Current attributes) replaces `current_user` helper
- `authenticate` before_action replaces `before_filter :authenticate`
- `require_admin` before_action replaces `admin_user` filter

### 4.4 Authorization
- Keep simple: owner checks (`current_user == resource.user`) and admin checks
- No need for Pundit/CanCanCan for this app's complexity

---

## Phase 5: Controllers

### 5.1 ApplicationController
- Include authentication concern
- Set up `Current.user` from session

### 5.2 UsersController
- Standard RESTful CRUD
- Strong parameters (replaces `attr_accessible`)
- `before_action :authenticate, only: [:index, :edit, :update, :destroy]`
- `before_action :authorize_user, only: [:edit, :update]`
- `before_action :authorize_admin, only: [:destroy]`

### 5.3 SessionsController
- `new`, `create`, `destroy`
- Flash messages for errors
- Redirect back or default to resumes path

### 5.4 ResumesController
- RESTful actions + custom: `my_resumes`, `user_resumes`
- Pagination with Pagy
- Strong params: `params.expect(resume: [:name])`

### 5.5 SectionsController
- RESTful actions + `my_sections`
- Strong params: `params.expect(section: [:section_type, :title, :content])`

### 5.6 ResumeSectionsController
- Manage adding/removing/reordering sections within a resume
- Turbo Stream responses for dynamic reordering (Hotwire upgrade!)

### 5.7 CommentsController
- Nested under resumes in routes
- Turbo Stream for inline comment posting (no page reload)

### 5.8 RatingsController
- Nested under resumes in routes
- Turbo Stream for inline star rating

---

## Phase 6: Routes

### 6.1 Modern RESTful routes (replaces `match` routes)
```ruby
Rails.application.routes.draw do
  root "pages#home"

  # Auth
  get "sign_up", to: "users#new"
  get "sign_in", to: "sessions#new"
  delete "sign_out", to: "sessions#destroy"
  resource :session, only: [:new, :create, :destroy]

  # Users
  resources :users

  # Resumes with nested comments and ratings
  resources :resumes do
    resources :comments, only: [:create, :edit, :update, :destroy]
    resources :ratings, only: [:create, :update, :destroy]
    resources :resume_sections, only: [:create, :update, :destroy], path: "sections"
  end

  # Standalone sections (user's reusable content library)
  resources :sections

  # Custom collection routes
  get "my/resumes", to: "resumes#my_resumes", as: :my_resumes
  get "my/sections", to: "sections#my_sections", as: :my_sections
  get "users/:id/resumes", to: "resumes#user_resumes", as: :user_resumes
end
```

---

## Phase 7: Views with Tailwind CSS + Hotwire

### 7.1 Layout
- Modern responsive layout with Tailwind
- Navigation bar with responsive mobile menu (Stimulus controller)
- Flash messages styled as dismissible alerts
- Footer

### 7.2 Pages
- Home page with hero section, CTA for sign up
- About page (optional)

### 7.3 User views
- Sign up / Sign in forms (styled with Tailwind)
- Profile page showing user's resumes with Gravatar (use `image_tag` with Gravatar URL directly, no gem needed)
- User settings (edit profile)
- Users index with pagination (admin)

### 7.4 Resume views
- Resume index (cards grid layout)
- Resume show page (formatted resume display with sections in order)
- Resume form (create/edit with name field)
- Resume builder: add/remove/reorder sections using Turbo Frames
- My Resumes dashboard
- Browse user resumes

### 7.5 Section views
- Section form with type dropdown and content textarea
- My Sections library view
- Section show (preview)

### 7.6 Comments
- Inline comment form on resume show page (Turbo Frame)
- Comment list with timestamps and user info

### 7.7 Ratings
- Star rating component (Stimulus controller for interactive stars)
- Display average rating on resume cards and show page

---

## Phase 8: Hotwire Enhancements

### 8.1 Turbo Frames
- Resume section management (add/remove sections without page reload)
- Comment form and list (inline updates)
- Rating widget (submit without page reload)

### 8.2 Turbo Streams
- Broadcast new comments to all viewers of a resume
- Live rating updates

### 8.3 Stimulus Controllers
- Star rating interactive widget
- Mobile nav toggle
- Flash message auto-dismiss
- Section reordering (drag and drop, optional stretch goal)

---

## Phase 9: Testing

### 9.1 Model specs
- User: validations, authentication, associations
- Resume: validations, associations, average_rating
- Section: validations, type constraints
- ResumeSection: ordering, uniqueness
- Comment: validations
- Rating: validations, score range, uniqueness per user/resume

### 9.2 Request/controller specs
- Users: CRUD, auth filters, admin-only destroy
- Sessions: sign in/out flows
- Resumes: CRUD, ownership checks
- Sections: CRUD, ownership
- Comments: create (authenticated), edit (owner only)
- Ratings: create/update (authenticated, one per user)

### 9.3 System specs (Capybara)
- User registration and sign in flow
- Create resume with sections
- View and comment on another user's resume
- Rate a resume
- Admin delete user

### 9.4 Factories (FactoryBot)
- User (with admin trait)
- Resume
- Section (with traits for each type)
- ResumeSection
- Comment
- Rating

---

## Phase 10: Seed Data & Polish

### 10.1 db/seeds.rb
- Port the old `sample_data.rake` logic
- Create admin user, sample users, resumes with sections, comments, ratings
- Use Faker for realistic data

### 10.2 Final polish
- Error pages (404, 500) styled with Tailwind
- Form error display (inline validation messages)
- Loading states for Turbo submissions
- Responsive design verification (mobile, tablet, desktop)
- README with setup instructions

---

## File Structure (New App)

```
roundfile/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── concerns/authentication.rb
│   │   ├── users_controller.rb
│   │   ├── sessions_controller.rb
│   │   ├── resumes_controller.rb
│   │   ├── sections_controller.rb
│   │   ├── resume_sections_controller.rb
│   │   ├── comments_controller.rb
│   │   ├── ratings_controller.rb
│   │   └── pages_controller.rb
│   ├── models/
│   │   ├── user.rb
│   │   ├── resume.rb
│   │   ├── section.rb
│   │   ├── resume_section.rb
│   │   ├── comment.rb
│   │   ├── rating.rb
│   │   └── current.rb
│   ├── views/
│   │   ├── layouts/application.html.erb
│   │   ├── shared/ (_flash, _navbar, _error_messages)
│   │   ├── pages/home.html.erb
│   │   ├── users/ (index, show, new, edit, _form, _user)
│   │   ├── sessions/ (new)
│   │   ├── resumes/ (index, show, new, edit, _form, _resume_card, my_resumes, user_resumes)
│   │   ├── sections/ (index, show, new, edit, _form, _section, my_sections)
│   │   ├── comments/ (_comment, _form)
│   │   ├── ratings/ (_rating, _form)
│   │   └── resume_sections/ (_resume_section, _form)
│   └── javascript/
│       └── controllers/
│           ├── star_rating_controller.js
│           ├── nav_controller.js
│           └── flash_controller.js
├── db/
│   ├── migrate/ (6 migration files)
│   └── seeds.rb
├── spec/
│   ├── models/ (6 model specs)
│   ├── requests/ (7 controller specs)
│   ├── system/ (5 system specs)
│   └── factories/ (6 factory files)
└── config/
    └── routes.rb
```

---

## Implementation Order

| Step | Phase | Description | Est. Files |
|------|-------|-------------|------------|
| 1 | Phase 1 | Generate Rails 8 app, configure gems, set up RSpec | ~5 |
| 2 | Phase 2 | Create all migrations, run `db:migrate` | 6 |
| 3 | Phase 3 | Build all 6 models with validations/associations | 6 |
| 4 | Phase 4 | Authentication (has_secure_password, sessions, Current) | 4 |
| 5 | Phase 5 | All controllers with strong params | 8 |
| 6 | Phase 6 | Routes | 1 |
| 7 | Phase 7 | Layout, nav, all views with Tailwind | ~30 |
| 8 | Phase 8 | Hotwire enhancements (Turbo Frames, Stimulus) | ~6 |
| 9 | Phase 9 | Full test suite | ~18 |
| 10 | Phase 10 | Seeds, polish, README | ~4 |

**Total: ~88 files across 10 phases**

---

## Key Modernization Wins

| Old (Rails 3) | New (Rails 8) |
|---|---|
| SHA2 + salt password hashing | `has_secure_password` (bcrypt) |
| `attr_accessible` mass assignment | Strong Parameters |
| `before_filter` | `before_action` |
| `match` routes | `get`/`post`/`delete` + nested resources |
| Prototype.js | Hotwire (Turbo + Stimulus) |
| Blueprint CSS | Tailwind CSS |
| `userid`, `resumeid` columns | `user_id`, `resume_id` (Rails conventions) |
| `will_paginate` | Pagy |
| `factory_girl` + `webrat` | FactoryBot + Capybara |
| Full page reloads | Turbo Frames/Streams |
| Signed cookies with salt | Secure sessions with tokens |
| No foreign keys in DB | Database-level foreign key constraints |
| SQLite everywhere | PostgreSQL |
