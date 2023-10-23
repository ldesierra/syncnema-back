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

ActiveRecord::Schema[7.0].define(version: 2023_10_22_212019) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cast_members", force: :cascade do |t|
    t.string "name"
    t.string "image"
    t.jsonb "awards"
    t.bigint "content_id"
    t.jsonb "occupations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_cast_members_on_content_id"
  end

  create_table "contents", force: :cascade do |t|
    t.string "type"
    t.string "title"
    t.string "imdb_id"
    t.string "tmdb_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "adult"
    t.text "overview"
    t.date "release"
    t.date "duration"
    t.string "image_url"
    t.string "content_rating"
    t.string "trailer_url"
  end

  create_table "favourites", force: :cascade do |t|
    t.bigint "content_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_favourites_on_content_id"
    t.index ["user_id"], name: "index_favourites_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "content_id", null: false
    t.bigint "user_id", null: false
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_ratings_on_content_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "streaming_sites", force: :cascade do |t|
    t.string "image_url"
    t.string "name"
    t.string "kind"
    t.bigint "content_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_streaming_sites_on_content_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id", null: false
  end

  add_foreign_key "favourites", "contents"
  add_foreign_key "favourites", "users"
  add_foreign_key "ratings", "contents"
  add_foreign_key "ratings", "users"
end
