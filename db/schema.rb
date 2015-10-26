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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151026155211) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "editions", force: :cascade do |t|
    t.integer  "guide_id"
    t.integer  "user_id"
    t.text     "title"
    t.text     "description"
    t.text     "body"
    t.string   "update_type"
    t.string   "phase"
    t.text     "publisher_title"
    t.text     "publisher_href"
    t.text     "related_discussion_href"
    t.text     "related_discussion_title"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "state"
    t.integer  "review_request_id"
  end

  create_table "guides", force: :cascade do |t|
    t.string "slug"
    t.string "content_id"
  end

  create_table "review_requests", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.text     "uid"
    t.text     "name"
    t.text     "email"
    t.text     "organisation_slug"
    t.text     "organisation_content_id"
    t.boolean  "remotely_signed_out",     default: false
    t.boolean  "disabled",                default: false
    t.text     "permissions",                                          array: true
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["organisation_content_id"], name: "index_users_on_organisation_content_id", using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

end
