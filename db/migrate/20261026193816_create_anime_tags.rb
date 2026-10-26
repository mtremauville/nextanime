class CreateAnimeTags < ActiveRecord::Migration[8.1]
  def change
    create_table :anime_tags do |t|
      t.references :anime, null: false, foreign_key: true, index: false
      t.references :tag, null: false, foreign_key: true
      t.integer :rank, null: false

      t.timestamps
    end

    add_index :anime_tags, %i[anime_id tag_id], unique: true
  end
end
