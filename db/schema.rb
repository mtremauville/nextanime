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

ActiveRecord::Schema[8.1].define(version: 2026_10_26_193816) do
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

  create_table "studios", force: :cascade do |t|
    t.integer "anilist_studio_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anilist_studio_id"], name: "index_studios_on_anilist_studio_id", unique: true
    t.index ["name"], name: "index_studios_on_name", unique: true
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

  add_foreign_key "anime_genres", "animes"
  add_foreign_key "anime_genres", "genres"
  add_foreign_key "anime_tags", "animes"
  add_foreign_key "anime_tags", "tags"
end
