# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120418224426) do

  create_table "comments", :force => true do |t|
    t.integer  "resumeid"
    t.integer  "userid"
    t.string   "comment"
    t.datetime "comment_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "resumeid"
    t.integer  "userid"
    t.integer  "rating_score"
    t.datetime "rate_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resumes", :force => true do |t|
    t.string   "name"
    t.integer  "userid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resumesection", :force => true do |t|
    t.integer  "resumeid"
    t.integer  "sectionid"
    t.integer  "orderNum"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resumesections", :force => true do |t|
    t.integer  "resumeid"
    t.integer  "sectionid"
    t.integer  "ordernum"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections", :force => true do |t|
    t.string   "typesection"
    t.string   "content"
    t.integer  "userid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",              :default => false
  end

end
