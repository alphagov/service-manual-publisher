# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_04_155614) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "approvals", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "edition_id"
    t.index ["edition_id"], name: "index_approvals_on_edition_id"
    t.index ["user_id"], name: "index_approvals_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "comment"
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.bigint "user_id"
    t.string "role", default: "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["commentable_type"], name: "index_comments_on_commentable_type"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "editions", force: :cascade do |t|
    t.bigint "guide_id"
    t.bigint "author_id"
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
    t.index ["guide_id"], name: "index_editions_on_guide_id"
  end

  create_table "guides", force: :cascade do |t|
    t.string "slug"
    t.string "content_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.tsvector "tsv"
    t.string "type"
    t.index ["content_id"], name: "index_guides_on_content_id"
    t.index ["tsv"], name: "guides_tsv_idx", using: :gin
  end

  create_table "redirects", force: :cascade do |t|
    t.text "content_id", null: false
    t.text "old_path", null: false
    t.text "new_path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_redirects_on_content_id"
  end

  create_table "slug_migrations", force: :cascade do |t|
    t.string "slug"
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content_id", null: false
    t.string "redirect_to"
    t.index ["content_id"], name: "index_slug_migrations_on_content_id"
    t.index ["slug"], name: "index_slug_migrations_on_slug", unique: true
  end

  create_table "topic_section_guides", force: :cascade do |t|
    t.integer "topic_section_id", null: false
    t.integer "guide_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guide_id"], name: "index_topic_section_guides_on_guide_id"
    t.index ["topic_section_id"], name: "index_topic_section_guides_on_topic_section_id"
  end

  create_table "topic_sections", force: :cascade do |t|
    t.integer "topic_id", null: false
    t.string "title"
    t.string "description"
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_topic_sections_on_topic_id"
  end

  create_table "topics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "path", null: false
    t.string "title", null: false
    t.string "description", null: false
    t.string "content_id"
    t.boolean "visually_collapsed", default: false
    t.boolean "include_on_homepage", default: true
    t.index ["content_id"], name: "index_topics_on_content_id"
  end

  create_table "users", force: :cascade do |t|
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
