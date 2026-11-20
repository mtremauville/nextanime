class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.integer :anilist_tag_id, null: false
      t.string :name, null: false
      t.string :category
      t.boolean :adult, null: false, default: false

      t.timestamps
    end

    add_index :tags, :anilist_tag_id, unique: true
  end
end
