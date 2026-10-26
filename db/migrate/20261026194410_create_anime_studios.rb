class CreateAnimeStudios < ActiveRecord::Migration[8.1]
  def change
    create_table :anime_studios do |t|
      t.references :anime, null: false, foreign_key: true, index: false
      t.references :studio, null: false, foreign_key: true
      t.boolean :main, null: false, default: false

      t.timestamps
    end

    add_index :anime_studios, %i[anime_id studio_id], unique: true
    add_index :anime_studios, :anime_id, unique: true, where: "main",
              name: "index_anime_studios_on_anime_id_where_main"
  end
end
