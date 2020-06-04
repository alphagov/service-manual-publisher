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

ActiveRecord::Schema.define(version: 2020_06_04_155614) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "approvals", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "edition_id"
    t.index ["edition_id"], name: "index_approvals_on_edition_id"
    t.index ["user_id"], name: "index_approvals_on_user_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "comment"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.integer "user_id"
    t.string "role", default: "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["commentable_type"], name: "index_comments_on_commentable_type"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "editions", id: :serial, force: :cascade do |t|
    t.integer "guide_id"
    t.integer "author_id"
    t.text "title"
    t.text "description"
    t.text "body"
    t.string "update_type"
    t.text "phase", default: "beta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "state"
    t.text "change_note"
    t.integer "content_owner_id"
    t.integer "version"
    t.integer "created_by_id"
    t.index ["author_id"], name: "index_editions_on_author_id"
    t.index ["content_owner_id"], name: "index_editions_on_content_owner_id"
    t.index ["guide_id"], name: "index_editions_on_guide_id"
  end

  create_table "guides", id: :serial, force: :cascade do |t|
    t.string "slug"
    t.string "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.tsvector "tsv"
    t.string "type"
    t.index ["content_id"], name: "index_guides_on_content_id"
    t.index ["tsv"], name: "guides_tsv_idx", using: :gin
  end

  create_table "redirects", id: :serial, force: :cascade do |t|
    t.text "content_id", null: false
    t.text "old_path", null: false
    t.text "new_path", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["content_id"], name: "index_redirects_on_content_id"
  end

  create_table "slug_migrations", id: :serial, force: :cascade do |t|
    t.string "slug"
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content_id", null: false
    t.string "redirect_to"
    t.index ["content_id"], name: "index_slug_migrations_on_content_id"
    t.index ["slug"], name: "index_slug_migrations_on_slug", unique: true
  end

  create_table "topic_section_guides", id: :serial, force: :cascade do |t|
    t.integer "topic_section_id", null: false
    t.integer "guide_id", null: false
    t.integer "position", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["guide_id"], name: "index_topic_section_guides_on_guide_id"
    t.index ["topic_section_id"], name: "index_topic_section_guides_on_topic_section_id"
  end

  create_table "topic_sections", id: :serial, force: :cascade do |t|
    t.integer "topic_id", null: false
    t.string "title"
    t.string "description"
    t.integer "position", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["topic_id"], name: "index_topic_sections_on_topic_id"
  end

  create_table "topics", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "path", null: false
    t.string "title", null: false
    t.string "description", null: false
    t.string "content_id"
    t.boolean "visually_collapsed", default: false
    t.boolean "include_on_homepage", default: true
    t.index ["content_id"], name: "index_topics_on_content_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.text "uid"
    t.text "name"
    t.text "email"
    t.text "organisation_slug"
    t.text "organisation_content_id"
    t.boolean "remotely_signed_out", default: false
    t.boolean "disabled", default: false
    t.text "permissions", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["organisation_content_id"], name: "index_users_on_organisation_content_id"
    t.index ["uid"], name: "index_users_on_uid"
  end

end
