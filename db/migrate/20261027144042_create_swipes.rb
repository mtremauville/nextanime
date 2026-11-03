class CreateSwipes < ActiveRecord::Migration[8.1]
  def change
    create_table :swipes do |t|
      t.references :taste_profile, null: false, foreign_key: true, index: false
      t.references :anime, null: false, foreign_key: true
      t.boolean :liked, null: false

      t.timestamps
    end

    add_index :swipes, [ :taste_profile_id, :anime_id ], unique: true
  end
end
