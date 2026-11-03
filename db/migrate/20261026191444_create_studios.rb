class CreateStudios < ActiveRecord::Migration[8.1]
  def change
    create_table :studios do |t|
      t.integer :anilist_studio_id, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :studios, :anilist_studio_id, unique: true
    add_index :studios, :name, unique: true
  end
end
