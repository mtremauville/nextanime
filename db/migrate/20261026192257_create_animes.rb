class CreateAnimes < ActiveRecord::Migration[8.1]
  def change
    create_table :animes do |t|
      t.integer :anilist_id, null: false
      t.string :title_romaji, null: false
      t.string :title_english
      t.string :title_native
      t.text :description
      t.string :cover_image_url
      t.string :banner_image_url
      t.string :format
      t.string :airing_status
      t.string :season
      t.integer :season_year
      t.integer :episodes
      t.integer :duration
      t.integer :average_score
      t.integer :popularity
      t.date :start_date
      t.date :end_date
      t.integer :next_episode
      t.datetime :next_airing_at
      t.datetime :synced_at

      t.timestamps
    end

    add_index :animes, :anilist_id, unique: true
  end
end
