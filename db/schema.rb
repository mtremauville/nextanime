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

ActiveRecord::Schema[8.1].define(version: 2026_10_27_145334) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "anime_genres", force: :cascade do |t|
    t.bigint "anime_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anime_id", "genre_id"], name: "index_anime_genres_on_anime_id_and_genre_id", unique: true
    t.index ["genre_id"], name: "index_anime_genres_on_genre_id"
  end

  create_table "anime_studios", force: :cascade do |t|
    t.bigint "anime_id", null: false
    t.bigint "studio_id", null: false
    t.boolean "main", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anime_id", "studio_id"], name: "index_anime_studios_on_anime_id_and_studio_id", unique: true
    t.index ["anime_id"], name: "index_anime_studios_on_anime_id_where_main", unique: true, where: "main"
    t.index ["studio_id"], name: "index_anime_studios_on_studio_id"
  end

  create_table "anime_tags", force: :cascade do |t|
    t.bigint "anime_id", null: false
    t.bigint "tag_id", null: false
    t.integer "rank", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anime_id", "tag_id"], name: "index_anime_tags_on_anime_id_and_tag_id", unique: true
    t.index ["tag_id"], name: "index_anime_tags_on_tag_id"
  end

  create_table "animes", force: :cascade do |t|
    t.integer "anilist_id", null: false
    t.string "title_romaji", null: false
    t.string "title_english"
    t.string "title_native"
    t.text "description"
    t.string "cover_image_url"
    t.string "banner_image_url"
    t.string "format"
    t.string "airing_status"
    t.string "season"
    t.integer "season_year"
    t.integer "episodes"
    t.integer "duration"
    t.integer "average_score"
    t.integer "popularity"
    t.date "start_date"
    t.date "end_date"
    t.integer "next_episode"
    t.datetime "next_airing_at"
    t.datetime "synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anilist_id"], name: "index_animes_on_anilist_id", unique: true
  end

  create_table "genres", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_genres_on_name", unique: true
  end

  create_table "recommendations", force: :cascade do |t|
    t.bigint "taste_profile_id", null: false
    t.bigint "anime_id", null: false
    t.decimal "score", precision: 5, scale: 4, null: false
    t.text "explanation"
    t.string "explanation_digest"
    t.datetime "explained_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anime_id"], name: "index_recommendations_on_anime_id"
    t.index ["taste_profile_id", "anime_id"], name: "index_recommendations_on_taste_profile_id_and_anime_id", unique: true
    t.index ["taste_profile_id", "score"], name: "index_recommendations_on_taste_profile_id_and_score"
  end

  create_table "studios", force: :cascade do |t|
    t.integer "anilist_studio_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anilist_studio_id"], name: "index_studios_on_anilist_studio_id", unique: true
    t.index ["name"], name: "index_studios_on_name", unique: true
  end

  create_table "swipes", force: :cascade do |t|
    t.bigint "taste_profile_id", null: false
    t.bigint "anime_id", null: false
    t.boolean "liked", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anime_id"], name: "index_swipes_on_anime_id"
    t.index ["taste_profile_id", "anime_id"], name: "index_swipes_on_taste_profile_id_and_anime_id", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.integer "anilist_tag_id", null: false
    t.string "name", null: false
    t.string "category"
    t.boolean "adult", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anilist_tag_id"], name: "index_tags_on_anilist_tag_id", unique: true
  end

  create_table "taste_profiles", force: :cascade do |t|
    t.bigint "user_id"
    t.string "session_token"
    t.jsonb "genre_weights", default: {}, null: false
    t.jsonb "tag_weights", default: {}, null: false
    t.string "digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_token"], name: "index_taste_profiles_on_session_token", unique: true, where: "(session_token IS NOT NULL)"
    t.index ["user_id"], name: "index_taste_profiles_on_user_id", unique: true, where: "(user_id IS NOT NULL)"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "username"
    t.string "country", default: "FR"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "anime_genres", "animes"
  add_foreign_key "anime_genres", "genres"
  add_foreign_key "anime_studios", "animes"
  add_foreign_key "anime_studios", "studios"
  add_foreign_key "anime_tags", "animes"
  add_foreign_key "anime_tags", "tags"
  add_foreign_key "recommendations", "animes"
  add_foreign_key "recommendations", "taste_profiles"
  add_foreign_key "swipes", "animes"
  add_foreign_key "swipes", "taste_profiles"
  add_foreign_key "taste_profiles", "users"
end
