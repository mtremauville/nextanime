class CreateTmdbMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :tmdb_matches do |t|
      t.references :anime, null: false, foreign_key: true, index: { unique: true }
      t.integer :tmdb_id
      t.string :media_type
      t.datetime :checked_at, null: false

      t.timestamps
    end

    add_check_constraint :tmdb_matches, "(tmdb_id IS NULL) = (media_type IS NULL)",
                         name: "tmdb_matches_id_and_media_type_together"
  end
end
