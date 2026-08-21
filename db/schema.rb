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

ActiveRecord::Schema[8.1].define(version: 2020_06_04_155614) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "approvals", id: :serial, force: :cascade do |t|
    t.integer "edition_id"
    t.integer "user_id"
    t.index ["edition_id"], name: "index_approvals_on_edition_id"
    t.index ["user_id"], name: "index_approvals_on_user_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "comment"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.datetime "created_at", precision: nil
    t.string "role", default: "comments"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["commentable_type"], name: "index_comments_on_commentable_type"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "editions", id: :serial, force: :cascade do |t|
    t.integer "author_id"
    t.text "body"
    t.text "change_note"
    t.integer "content_owner_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "created_by_id"
    t.text "description"
    t.integer "guide_id"
    t.text "phase", default: "beta"
    t.text "state"
    t.text "title"
    t.string "update_type"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "version"
    t.index ["author_id"], name: "index_editions_on_author_id"
    t.index ["content_owner_id"], name: "index_editions_on_content_owner_id"
    t.index ["guide_id"], name: "index_editions_on_guide_id"
  end

  create_table "guides", id: :serial, force: :cascade do |t|
    t.string "content_id"
    t.datetime "created_at", precision: nil
    t.string "slug"
    t.tsvector "tsv"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.index ["content_id"], name: "index_guides_on_content_id"
    t.index ["tsv"], name: "guides_tsv_idx", using: :gin
  end

  create_table "redirects", id: :serial, force: :cascade do |t|
    t.text "content_id", null: false
    t.datetime "created_at", precision: nil
    t.text "new_path", null: false
    t.text "old_path", null: false
    t.datetime "updated_at", precision: nil
    t.index ["content_id"], name: "index_redirects_on_content_id"
  end

  create_table "slug_migrations", id: :serial, force: :cascade do |t|
    t.boolean "completed", default: false, null: false
    t.string "content_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "redirect_to"
    t.string "slug"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["content_id"], name: "index_slug_migrations_on_content_id"
    t.index ["slug"], name: "index_slug_migrations_on_slug", unique: true
  end

  create_table "topic_section_guides", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "guide_id", null: false
    t.integer "position", null: false
    t.integer "topic_section_id", null: false
    t.datetime "updated_at", precision: nil
    t.index ["guide_id"], name: "index_topic_section_guides_on_guide_id"
    t.index ["topic_section_id"], name: "index_topic_section_guides_on_topic_section_id"
  end

  create_table "topic_sections", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "description"
    t.integer "position", null: false
    t.string "title"
    t.integer "topic_id", null: false
    t.datetime "updated_at", precision: nil
    t.index ["topic_id"], name: "index_topic_sections_on_topic_id"
  end

  create_table "topics", id: :serial, force: :cascade do |t|
    t.string "content_id"
    t.datetime "created_at", precision: nil
    t.string "description", null: false
    t.boolean "include_on_homepage", default: true
    t.string "path", null: false
    t.string "title", null: false
    t.datetime "updated_at", precision: nil
    t.boolean "visually_collapsed", default: false
    t.index ["content_id"], name: "index_topics_on_content_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.boolean "disabled", default: false
    t.text "email"
    t.text "name"
    t.text "organisation_content_id"
    t.text "organisation_slug"
    t.text "permissions", array: true
    t.boolean "remotely_signed_out", default: false
    t.text "uid"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["organisation_content_id"], name: "index_users_on_organisation_content_id"
    t.index ["uid"], name: "index_users_on_uid"
  end
end
