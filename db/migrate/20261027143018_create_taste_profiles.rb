class CreateTasteProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :taste_profiles do |t|
      t.references :user, foreign_key: true,
                          index: { unique: true, where: "user_id IS NOT NULL" }
      t.string :session_token
      t.jsonb :genre_weights, null: false, default: {}
      t.jsonb :tag_weights, null: false, default: {}
      t.string :digest

      t.timestamps
    end

    add_index :taste_profiles, :session_token, unique: true,
                                               where: "session_token IS NOT NULL"
  end
end
