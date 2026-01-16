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

ActiveRecord::Schema[8.1].define(version: 2025_10_03_113429) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "followers_count", default: 0
    t.citext "name"
    t.bigint "owner_id"
    t.string "owner_type"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_accounts_on_name", unique: true
    t.index ["owner_type", "owner_id"], name: "index_accounts_on_owner"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.bigint "user_id"
    t.bigint "visit_id"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "app_version"
    t.string "browser"
    t.string "city"
    t.string "country"
    t.string "device_type"
    t.string "ip"
    t.text "landing_page"
    t.float "latitude"
    t.float "longitude"
    t.string "os"
    t.string "os_version"
    t.string "platform"
    t.text "referrer"
    t.string "referring_domain"
    t.string "region"
    t.datetime "started_at"
    t.text "user_agent"
    t.bigint "user_id"
    t.string "utm_campaign"
    t.string "utm_content"
    t.string "utm_medium"
    t.string "utm_source"
    t.string "utm_term"
    t.string "visit_token"
    t.string "visitor_token"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "attachments", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.string "key"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["account_id"], name: "index_attachments_on_account_id"
    t.index ["key"], name: "index_attachments_on_key", unique: true
    t.index ["user_id"], name: "index_attachments_on_user_id"
  end

  create_table "authors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "post_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["post_id", "user_id"], name: "index_authors_on_post_id_and_user_id", unique: true
    t.index ["post_id"], name: "index_authors_on_post_id"
    t.index ["user_id"], name: "index_authors_on_user_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "post_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["post_id", "user_id"], name: "index_bookmarks_on_post_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "commentable_id"
    t.string "commentable_type"
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "likes_count", default: 0
    t.bigint "parent_id"
    t.integer "replies_count", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "exports", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_exports_on_account_id"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["account_id", "user_id"], name: "index_follows_on_account_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "likable_id", null: false
    t.string "likable_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["likable_type", "likable_id", "user_id"], name: "index_likes_on_likable_type_and_likable_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "members", force: :cascade do |t|
    t.datetime "actived_at", precision: nil
    t.datetime "created_at", null: false
    t.citext "invitation_email"
    t.string "invitation_token"
    t.datetime "invited_at", precision: nil
    t.bigint "inviter_id"
    t.bigint "organization_id"
    t.integer "role"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["inviter_id"], name: "index_members_on_inviter_id"
    t.index ["organization_id", "user_id"], name: "index_members_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_members_on_organization_id"
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data", default: {}
    t.datetime "read_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id", "read_at"], name: "index_notifications_on_unread", where: "(read_at IS NULL)"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "post_revisions", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "post_id"
    t.integer "status", default: 0
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["post_id"], name: "index_post_revisions_on_post_id"
    t.index ["user_id"], name: "index_post_revisions_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "account_id"
    t.boolean "allow_comments", default: true
    t.integer "bookmarks_count", default: 0
    t.string "canonical_url"
    t.integer "comments_count", default: 0
    t.text "content"
    t.datetime "created_at", null: false
    t.text "excerpt"
    t.boolean "featured", default: false
    t.integer "likes_count", default: 0
    t.string "preview_token"
    t.datetime "published_at", precision: nil
    t.boolean "restricted", default: false
    t.integer "score", default: 0
    t.integer "status", default: 0
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "views_count", default: 0
    t.index ["account_id"], name: "index_posts_on_account_id"
    t.index ["published_at"], name: "index_posts_on_published_at"
    t.index ["score"], name: "index_posts_on_score"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.text "global_head_html"
    t.string "name"
    t.text "sidebar_footer_html"
    t.text "sidebar_header_html"
    t.text "site_footer_html"
    t.text "site_header_html"
    t.datetime "updated_at", null: false
    t.boolean "weekly_digest_email_enabled", default: true, null: false
    t.text "weekly_digest_footer_html"
    t.text "weekly_digest_header_html"
  end

  create_table "taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tag_id"
    t.bigint "taggable_id"
    t.string "taggable_type"
    t.datetime "updated_at", null: false
    t.index ["tag_id", "taggable_type", "taggable_id"], name: "index_tag_taggable_uniqueness", unique: true
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.citext "name"
    t.integer "taggings_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.text "bio"
    t.boolean "comment_email_notification_enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.citext "email", null: false
    t.boolean "email_notification_enabled", default: true, null: false
    t.datetime "email_verified_at", precision: nil
    t.integer "followings_count", default: 0
    t.string "name", null: false
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.boolean "weekly_digest_email_enabled", default: true, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "taggings", "tags"
end
