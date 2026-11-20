class CreateRecommendations < ActiveRecord::Migration[8.1]
  def change
    create_table :recommendations do |t|
      t.references :taste_profile, null: false, foreign_key: true, index: false
      t.references :anime, null: false, foreign_key: true
      t.decimal :score, null: false, precision: 5, scale: 4
      t.text :explanation
      t.string :explanation_digest
      t.datetime :explained_at

      t.timestamps
    end

    add_index :recommendations, [ :taste_profile_id, :anime_id ], unique: true
    add_index :recommendations, [ :taste_profile_id, :score ]
  end
end
