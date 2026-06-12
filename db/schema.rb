# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_21_000008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "resume_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["resume_id"], name: "index_comments_on_resume_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "resume_id", null: false
    t.integer "score", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["resume_id", "user_id"], name: "index_ratings_on_resume_id_and_user_id", unique: true
    t.index ["resume_id"], name: "index_ratings_on_resume_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "resume_sections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.bigint "resume_id", null: false
    t.bigint "section_id", null: false
    t.datetime "updated_at", null: false
    t.index ["resume_id", "section_id"], name: "index_resume_sections_on_resume_id_and_section_id", unique: true
    t.index ["resume_id"], name: "index_resume_sections_on_resume_id"
    t.index ["section_id"], name: "index_resume_sections_on_section_id"
  end

  create_table "resumes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_resumes_on_user_id"
  end

  create_table "sections", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "section_type", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sections_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "password_reset_sent_at"
    t.string "password_reset_token_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["password_reset_token_digest"], name: "index_users_on_password_reset_token_digest", unique: true
  end

  add_foreign_key "comments", "resumes"
  add_foreign_key "comments", "users"
  add_foreign_key "ratings", "resumes"
  add_foreign_key "ratings", "users"
  add_foreign_key "resume_sections", "resumes"
  add_foreign_key "resume_sections", "sections"
  add_foreign_key "resumes", "users"
  add_foreign_key "sections", "users"
end
